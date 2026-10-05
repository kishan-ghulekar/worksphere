// functions/index.js  (WorkSphere: real Razorpay flow)
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");
const crypto = require("crypto");

admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

// Secrets live ONLY on the server (never in Flutter).
const KEY_ID = defineSecret("RAZORPAY_KEY_ID");
const KEY_SECRET = defineSecret("RAZORPAY_KEY_SECRET");
const WEBHOOK_SECRET = defineSecret("RAZORPAY_WEBHOOK_SECRET");
const OPTS = { secrets: [KEY_ID, KEY_SECRET] };

function requireAuth(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Please sign in.");
  return uid;
}

function requireString(data, field) {
  const v = data && data[field];
  if (typeof v !== "string" || v.length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return v;
}

function safeEqual(a, b) {
  const x = Buffer.from(a);
  const y = Buffer.from(b);
  return x.length === y.length && crypto.timingSafeEqual(x, y);
}

// ---------------------------------------------------------------------
// 1) createOrder: Flutter sends ONLY contractId. The amount is read from
//    Firestore (contracts/{id}.agreedAmount), never from the app.
// ---------------------------------------------------------------------
exports.createOrder = onCall(OPTS, async (request) => {
  const uid = requireAuth(request);
  const contractId = requireString(request.data, "contractId");

  const contractSnap = await db.collection("contracts").doc(contractId).get();
  if (!contractSnap.exists) {
    throw new HttpsError("not-found", "Contract not found.");
  }
  const c = contractSnap.data();

  if (c.clientId !== uid) {
    throw new HttpsError("permission-denied", "Not your contract.");
  }
  if (c.status !== "completed") {
    throw new HttpsError("failed-precondition",
      "Contract must be completed before payment.");
  }
  if (c.paymentStatus === "success") {
    throw new HttpsError("already-exists", "Already paid.");
  }

  const amountRupees = Number(c.agreedAmount);
  if (!Number.isFinite(amountRupees) || amountRupees < 1) {
    throw new HttpsError("invalid-argument", "Invalid amount.");
  }
  const amountPaise = Math.round(amountRupees * 100);

  // ONE payment document per contract: payments/{contractId}
  const paymentRef = db.collection("payments").doc(contractId);
  const paymentSnap = await paymentRef.get();
  if (paymentSnap.exists && paymentSnap.data().status === "success") {
    throw new HttpsError("already-exists", "Already paid.");
  }

  const razorpay = new Razorpay({
    key_id: KEY_ID.value(),
    key_secret: KEY_SECRET.value(),
  });

  let order;
  try {
    order = await razorpay.orders.create({
      amount: amountPaise,
      currency: "INR",
      receipt: contractId.substring(0, 40),
      notes: { contractId, clientId: uid },
    });
  } catch (e) {
    logger.error("Razorpay order creation failed", e);
    throw new HttpsError("internal", "Could not create order.");
  }

  const data = {
    paymentId: paymentRef.id,
    contractId,
    projectId: c.projectId || contractId,
    projectTitle: c.projectTitle || "",
    clientId: c.clientId,
    clientName: c.clientName || "",
    freelancerId: c.freelancerId,
    freelancerName: c.freelancerName || "",
    amount: amountRupees,
    currency: "INR",
    razorpayOrderId: order.id,
    razorpayPaymentId: null,
    status: "pending",
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (!paymentSnap.exists) data.createdAt = FieldValue.serverTimestamp();
  await paymentRef.set(data, { merge: true });

  return {
    key: KEY_ID.value(), // public key id, safe to send to the app
    orderId: order.id,
    paymentDocId: paymentRef.id,
    amount: amountPaise,
    currency: "INR",
  };
});

// ---------------------------------------------------------------------
// 2) verifyPayment: the ONLY app-triggered place a payment becomes success.
// ---------------------------------------------------------------------
exports.verifyPayment = onCall(OPTS, async (request) => {
  const uid = requireAuth(request);
  const paymentDocId = requireString(request.data, "paymentDocId");
  const orderId = requireString(request.data, "razorpayOrderId");
  const paymentId = requireString(request.data, "razorpayPaymentId");
  const signature = requireString(request.data, "razorpaySignature");

  const paymentRef = db.collection("payments").doc(paymentDocId);
  const snap = await paymentRef.get();
  if (!snap.exists) throw new HttpsError("not-found", "Payment not found.");
  const p = snap.data();

  if (p.clientId !== uid) {
    throw new HttpsError("permission-denied", "Not your payment.");
  }
  if (p.status === "success") return { success: true, alreadyVerified: true };
  if (p.razorpayOrderId !== orderId) {
    throw new HttpsError("invalid-argument", "Order mismatch.");
  }

  // Razorpay signature = HMAC_SHA256(order_id + "|" + payment_id, secret)
  const expected = crypto
    .createHmac("sha256", KEY_SECRET.value())
    .update(`${orderId}|${paymentId}`)
    .digest("hex");

  if (!safeEqual(expected, signature)) {
    await paymentRef.update({
      status: "failed",
      updatedAt: FieldValue.serverTimestamp(),
    });
    throw new HttpsError("aborted", "Signature verification failed.");
  }

  const batch = db.batch();
  batch.update(paymentRef, {
    status: "success",
    razorpayPaymentId: paymentId,
    paidAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
  batch.update(db.collection("contracts").doc(p.contractId), {
    paymentStatus: "success",
  });
  await batch.commit();

  return { success: true };
});

// ---------------------------------------------------------------------
// 3) markPaymentCancelled: user closed the Razorpay sheet.
// ---------------------------------------------------------------------
exports.markPaymentCancelled = onCall(async (request) => {
  const uid = requireAuth(request);
  const paymentDocId = requireString(request.data, "paymentDocId");

  const ref = db.collection("payments").doc(paymentDocId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Payment not found.");
  const p = snap.data();

  if (p.clientId !== uid) {
    throw new HttpsError("permission-denied", "Not your payment.");
  }
  if (p.status === "pending" || p.status === "processing") {
    await ref.update({
      status: "cancelled",
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
  return { success: true };
});

// ---------------------------------------------------------------------
// 4) razorpayWebhook: safety net. If the app dies after the customer
//    paid, Razorpay still tells the server and the payment is recorded.
// ---------------------------------------------------------------------
exports.razorpayWebhook = onRequest(
  { secrets: [WEBHOOK_SECRET] },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const signature = req.get("x-razorpay-signature") || "";
    const expected = crypto
      .createHmac("sha256", WEBHOOK_SECRET.value())
      .update(req.rawBody)
      .digest("hex");
    if (!safeEqual(expected, signature)) {
      res.status(400).send("Invalid signature");
      return;
    }

    try {
      if (req.body && req.body.event === "payment.captured") {
        const entity = req.body.payload.payment.entity;
        const q = await db.collection("payments")
          .where("razorpayOrderId", "==", entity.order_id)
          .limit(1)
          .get();

        if (!q.empty) {
          const doc = q.docs[0];
          const p = doc.data();
          const amountOk = entity.amount === Math.round(p.amount * 100);
          if (p.status !== "success" && amountOk) {
            const batch = db.batch();
            batch.update(doc.ref, {
              status: "success",
              razorpayPaymentId: entity.id,
              paidAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
            });
            batch.update(db.collection("contracts").doc(p.contractId), {
              paymentStatus: "success",
            });
            await batch.commit();
          }
        }
      }
      res.status(200).send("ok");
    } catch (e) {
      logger.error("Webhook error", e);
      res.status(500).send("error");
    }
  });