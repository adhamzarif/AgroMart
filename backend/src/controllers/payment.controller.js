import axios from 'axios';
import qs from 'qs';

// Local development-এ initiated transaction-এর amount মনে রাখার জন্য.
// Production-এ অবশ্যই DB-তে payment/order record রাখা উচিত।
const pendingTransactions = new Map();

const SERVER_URL = process.env.SERVER_URL || 'http://localhost:4000';
const CLIENT_ORIGIN =
  process.env.CLIENT_ORIGIN || 'http://localhost:5173';

const SSLCOMMERZ_SESSION_URL =
  process.env.SSLCOMMERZ_IS_SANDBOX === 'true' ||
  process.env.SSLCOMMERZ_IS_SANDBOX === true
    ? 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php'
    : 'https://securepay.sslcommerz.com/gwprocess/v4/api.php';

const SSLCOMMERZ_VALIDATION_URL =
  process.env.SSLCOMMERZ_IS_SANDBOX === 'true' ||
  process.env.SSLCOMMERZ_IS_SANDBOX === true
    ? 'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php'
    : 'https://securepay.sslcommerz.com/validator/api/validationserverAPI.php';

/**
 * Amount clean/validate করার helper
 */
const normalizeAmount = (value) => {
  const amount = Number(value);

  if (!Number.isFinite(amount) || amount <= 0) {
    return null;
  }

  return Number(amount.toFixed(2));
};

/**
 * SSLCommerz validation API call
 */
const validateSSLCommerzPayment = async (valId) => {
  if (!process.env.STORE_ID || !process.env.STORE_PASSWORD) {
    throw new Error('SSLCommerz credentials are missing in backend/.env');
  }

  const response = await axios.get(SSLCOMMERZ_VALIDATION_URL, {
    params: {
      val_id: valId,
      store_id: process.env.STORE_ID,
      store_passwd: process.env.STORE_PASSWORD,
      format: 'json',
      v: 1,
    },
    timeout: 15000,
  });

  return response.data;
};

/**
 * Callback body থেকে tran_id/val_id নেওয়া।
 * SSLCommerz সাধারণত POST data পাঠায়।
 * Query fallback-ও রাখা হয়েছে local testing-এর সুবিধার জন্য।
 */
const getPaymentData = (req) => {
  return {
    ...req.query,
    ...req.body,
  };
};

// ============================================================
// 1. INITIATE PAYMENT
// ============================================================
export const initiatePayment = async (req, res, next) => {
  try {
    if (!process.env.STORE_ID || !process.env.STORE_PASSWORD) {
      return res.status(500).json({
        success: false,
        message:
          'SSLCommerz credentials are missing. Please check backend/.env',
      });
    }

    const {
      amount,
      tran_id,
      cus_name,
      cus_email,
      cus_phone,
      customerName,
      customerEmail,
      customerPhone,
      cartItems,
    } = req.body;

    const totalAmount = normalizeAmount(amount);

    if (totalAmount === null) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment amount.',
      });
    }

    // IMPORTANT: transaction ID একবারই তৈরি হবে
    const transactionId =
      typeof tran_id === 'string' && tran_id.trim()
        ? tran_id.trim()
        : `AGRO_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

    const customerNameValue =
      cus_name ||
      customerName ||
      'AgroMart Customer';

    const customerEmailValue =
      cus_email ||
      customerEmail ||
      'customer@agromart.com';

    const customerPhoneValue =
      cus_phone ||
      customerPhone ||
      '01700000000';

    // Cart-এর product name নেওয়া, না থাকলে default
    const productName =
      Array.isArray(cartItems) && cartItems.length > 0
        ? cartItems
            .map(
              (item) =>
                item?.crop_name_en ||
                item?.name ||
                item?.title ||
                'AgroMart Product'
            )
            .join(', ')
            .slice(0, 100)
        : 'AgroMart Product';

    const postData = {
      store_id: process.env.STORE_ID,
      store_passwd: process.env.STORE_PASSWORD,

      total_amount: totalAmount,
      currency: 'BDT',
      tran_id: transactionId,

      success_url: `${SERVER_URL}/api/payment/success`,
      fail_url: `${SERVER_URL}/api/payment/fail`,
      cancel_url: `${SERVER_URL}/api/payment/cancel`,
      ipn_url: `${SERVER_URL}/api/payment/ipn`,

      cus_name: customerNameValue,
      cus_email: customerEmailValue,
      cus_add1: 'Dhaka',
      cus_add2: 'Dhaka',
      cus_city: 'Dhaka',
      cus_state: 'Dhaka',
      cus_postcode: '1200',
      cus_country: 'Bangladesh',
      cus_phone: customerPhoneValue,

      shipping_method: 'NO',
      product_name: productName,
      product_category: 'Agriculture',
      product_profile: 'general',
    };

    console.log(
      `[SSLCommerz] Initiating payment: ${transactionId} | Amount: ${totalAmount}`
    );

    const response = await axios.post(
      SSLCOMMERZ_SESSION_URL,
      qs.stringify(postData),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        timeout: 15000,
      }
    );

    const sslResponse = response.data;

    if (
      sslResponse &&
      sslResponse.status === 'SUCCESS' &&
      sslResponse.GatewayPageURL
    ) {
      // Local verification-এর জন্য amount save করছি
      pendingTransactions.set(transactionId, {
        amount: totalAmount,
        currency: 'BDT',
        createdAt: Date.now(),
      });

      // 30 মিনিট পরে cleanup
      const timer = setTimeout(() => {
        pendingTransactions.delete(transactionId);
      }, 30 * 60 * 1000);

      // Node process বন্ধ হতে timer বাধা না দিক
      timer.unref?.();

      return res.status(200).json({
        success: true,
        tran_id: transactionId,
        gatewayUrl: sslResponse.GatewayPageURL,
      });
    }

    console.error(
      '[SSLCommerz] Session creation failed:',
      sslResponse
    );

    return res.status(400).json({
      success: false,
      message: 'SSLCommerz Session Creation Failed',
      reason:
        sslResponse?.failedreason ||
        sslResponse?.failed_reason ||
        'Unknown error',
    });
  } catch (error) {
    console.error(
      '[SSLCommerz] Initiation error:',
      error.response?.data || error.message
    );

    next(error);
  }
};

// ============================================================
// 2. PAYMENT SUCCESS
// ============================================================
export const paymentSuccess = async (req, res, next) => {
  try {
    const data = getPaymentData(req);

    const transactionId = data.tran_id;
    const valId = data.val_id;

    if (!transactionId || !valId) {
      return res.redirect(
        `${CLIENT_ORIGIN}/marketplace?payment=failed&reason=missing_data`
      );
    }

    const pendingPayment = pendingTransactions.get(transactionId);

    if (!pendingPayment) {
      return res.redirect(
        `${CLIENT_ORIGIN}/marketplace?payment=failed&reason=transaction_not_found&tran_id=${encodeURIComponent(
          transactionId
        )}`
      );
    }

    // SSLCommerz-এর server দিয়ে payment validate
    const validation = await validateSSLCommerzPayment(valId);

    console.log('[SSLCommerz] Validation response:', validation);

    const validationStatus = String(validation?.status || '').toUpperCase();

    const returnedTransactionId = String(
      validation?.tran_id || ''
    );

    const returnedAmount = normalizeAmount(validation?.amount);

    const returnedCurrency = String(
      validation?.currency || ''
    ).toUpperCase();

    // Security checks
    const isValidStatus =
      validationStatus === 'VALID' ||
      validationStatus === 'VALIDATED';

    const isValidTransaction =
      returnedTransactionId === transactionId;

    const isValidAmount =
      returnedAmount !== null &&
      returnedAmount === pendingPayment.amount;

    const isValidCurrency =
      returnedCurrency === pendingPayment.currency;

    if (
      !isValidStatus ||
      !isValidTransaction ||
      !isValidAmount ||
      !isValidCurrency
    ) {
      console.error('[SSLCommerz] Validation check failed:', {
        validationStatus,
        returnedTransactionId,
        transactionId,
        returnedAmount,
        expectedAmount: pendingPayment.amount,
        returnedCurrency,
        expectedCurrency: pendingPayment.currency,
      });

      pendingTransactions.delete(transactionId);

      return res.redirect(
        `${CLIENT_ORIGIN}/marketplace?payment=failed&reason=validation_failed&tran_id=${encodeURIComponent(
          transactionId
        )}`
      );
    }

    // এখানে DB payment/order status = success করা উচিত
    // তোমাদের existing order DB flow অনুযায়ী পরে UPDATE করা যাবে.

    pendingTransactions.delete(transactionId);

    return res.redirect(
      `${CLIENT_ORIGIN}/marketplace?payment=success&tran_id=${encodeURIComponent(
        transactionId
      )}`
    );
  } catch (error) {
    console.error(
      '[SSLCommerz] Success handler error:',
      error.response?.data || error.message
    );

    const data = getPaymentData(req);
    const transactionId = data.tran_id || '';

    return res.redirect(
      `${CLIENT_ORIGIN}/marketplace?payment=failed&reason=server_error&tran_id=${encodeURIComponent(
        transactionId
      )}`
    );
  }
};

// ============================================================
// 3. PAYMENT FAIL
// ============================================================
export const paymentFail = async (req, res, next) => {
  try {
    const data = getPaymentData(req);
    const transactionId = data.tran_id || '';

    if (transactionId) {
      pendingTransactions.delete(transactionId);
    }

    return res.redirect(
      `${CLIENT_ORIGIN}/marketplace?payment=failed&tran_id=${encodeURIComponent(
        transactionId
      )}`
    );
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 4. PAYMENT CANCEL
// ============================================================
export const paymentCancel = async (req, res, next) => {
  try {
    const data = getPaymentData(req);
    const transactionId = data.tran_id || '';

    if (transactionId) {
      pendingTransactions.delete(transactionId);
    }

    return res.redirect(
      `${CLIENT_ORIGIN}/marketplace?payment=cancelled&tran_id=${encodeURIComponent(
        transactionId
      )}`
    );
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 5. IPN
// ============================================================
export const paymentIPN = async (req, res, next) => {
  try {
    const data = req.body || {};

    console.log('[SSLCommerz] IPN received:', data);

    const transactionId = data.tran_id;
    const status = String(data.status || '').toUpperCase();

    if (!transactionId) {
      return res.status(400).send('Missing tran_id');
    }

    const pendingPayment = pendingTransactions.get(transactionId);

    // Successful IPN
    if (
      (status === 'VALID' || status === 'VALIDATED') &&
      data.val_id
    ) {
      const validation = await validateSSLCommerzPayment(
        data.val_id
      );

      const validationStatus = String(
        validation?.status || ''
      ).toUpperCase();

      const returnedTransactionId = String(
        validation?.tran_id || ''
      );

      const returnedAmount = normalizeAmount(validation?.amount);

      const returnedCurrency = String(
        validation?.currency || ''
      ).toUpperCase();

      const valid =
        (validationStatus === 'VALID' ||
          validationStatus === 'VALIDATED') &&
        returnedTransactionId === transactionId &&
        pendingPayment &&
        returnedAmount === pendingPayment.amount &&
        returnedCurrency === pendingPayment.currency;

      if (!valid) {
        console.error(
          '[SSLCommerz] IPN validation failed:',
          validation
        );

        return res
          .status(400)
          .send('IPN validation failed');
      }

      // এখানে DB-তে payment/order status = success update করা উচিত
      pendingTransactions.delete(transactionId);

      console.log(
        `[SSLCommerz] IPN validated successfully: ${transactionId}`
      );

      return res.status(200).send('IPN processed');
    }

    // Failed/cancelled/pending payment
    if (
      status === 'FAILED' ||
      status === 'CANCELLED' ||
      status === 'CANCELED'
    ) {
      pendingTransactions.delete(transactionId);
    }

    return res.status(200).send('IPN Received');
  } catch (error) {
    console.error(
      '[SSLCommerz] IPN error:',
      error.response?.data || error.message
    );

    next(error);
  }
};