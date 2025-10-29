# Subscription Setup Guide

## App Store Connect Configuration

### Step 1: Create In-App Purchases

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app (Interval)
3. Go to **Features** → **In-App Purchases and Subscriptions**
4. Click the **+** button to create a new subscription group

### Step 2: Create Subscription Group

1. **Reference Name**: `Interval Premium`
2. Click **Create**

### Step 3: Add Subscriptions

Create two auto-renewable subscriptions:

#### Annual Subscription
- **Reference Name**: `Interval Annual`
- **Product ID**: `com.brainfood.interval.subscription.annual`
- **Subscription Duration**: 1 Year
- **Price**: $59.99 USD (or your regional equivalent)
- **Subscription Localizations**:
  - **Display Name**: Interval Annual
  - **Description**: Get unlimited access to all Interval articles for one year. Best value at just $5/month.

#### Monthly Subscription
- **Reference Name**: `Interval Monthly`  
- **Product ID**: `com.brainfood.interval.subscription.monthly`
- **Subscription Duration**: 1 Month
- **Price**: $7.99 USD (or your regional equivalent)
- **Subscription Localizations**:
  - **Display Name**: Interval Monthly
  - **Description**: Get unlimited access to all Interval articles, billed monthly.

### Step 4: Set Up Introductory Offers (Optional)

If you want to offer a free trial or discount:
1. Click on each subscription
2. Scroll to **Introductory Offers**
3. Configure as desired (e.g., 7-day free trial)

### Step 5: Submit for Review

1. Add screenshots for subscriptions
2. Add app metadata for subscription features
3. Complete subscription review information
4. Submit the subscriptions for review along with your app

---

## Testing Subscriptions

### Create Sandbox Test Account

1. Go to **Users and Access** → **Sandbox Testers**
2. Click **+** to add a new tester
3. Use a unique email (doesn't need to be real)
4. Note the email and password

### Test in Xcode

1. Run the app on a device or simulator
2. When prompted to sign in for purchase, use your sandbox account
3. Sandbox subscriptions renew quickly (e.g., 1 year = 1 hour)
4. Test purchase flows, restoration, and cancellation

### StoreKit Configuration File (Optional)

For local testing without internet:
1. In Xcode: **File** → **New** → **File** → **StoreKit Configuration File**
2. Add your product IDs manually
3. Set prices and durations
4. Run app with StoreKit configuration selected

---

## Supabase Database Setup

You need to add subscription fields to your `users` table:

```sql
ALTER TABLE users 
ADD COLUMN subscription_tier TEXT DEFAULT 'free',
ADD COLUMN subscription_expires_at TIMESTAMPTZ,
ADD COLUMN subscription_platform TEXT;
```

Create an index for faster queries:

```sql
CREATE INDEX idx_users_subscription 
ON users(subscription_tier, subscription_expires_at);
```

---

## Important Product IDs

These are hardcoded in `SubscriptionManager.swift`:

- **Monthly**: `com.brainfood.interval.subscription.monthly`
- **Annual**: `com.brainfood.interval.subscription.annual`

⚠️ **These MUST match exactly in App Store Connect**

---

## Revenue & Analytics

Once live, track subscriptions in:
- **App Store Connect** → **Sales and Trends**
- **App Store Connect** → **Payments and Financial Reports**
- Consider integrating analytics (PostHog, Mixpanel, etc.)

---

## Next Steps

1. ✅ Configure products in App Store Connect
2. ✅ Test with sandbox account
3. ✅ Update Supabase schema
4. ✅ Submit app for review with subscriptions
5. Monitor subscription metrics post-launch
