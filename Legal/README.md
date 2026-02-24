# Legal Documents for App Store Submission

## Files Included

1. **privacy-policy.html** - Privacy Policy page
2. **terms-of-service.html** - Terms of Service page

## Required Steps Before App Store Submission

### 1. Host These Files Online

You need to host these HTML files on a public URL. Options include:

- **GitHub Pages** (free): Create a repository and enable GitHub Pages
- **Your own website**: Upload to your web hosting
- **Firebase Hosting** (free tier available)
- **Netlify** (free tier available)

### 2. Update URLs in the App

Once hosted, update these files with your actual URLs:

**File: `30DayBibleChallenge/App/ContentView.swift`**
```swift
// Around line 379, update:
if let url = URL(string: "https://YOUR-DOMAIN.com/privacy-policy.html") {
```

**File: `30DayBibleChallenge/Views/Premium/PaywallView.swift`**
```swift
// Around lines 217 and 220, update:
Link("Privacy Policy", destination: URL(string: "https://YOUR-DOMAIN.com/privacy-policy.html")!)
Link("Terms of Service", destination: URL(string: "https://YOUR-DOMAIN.com/terms-of-service.html")!)
```

### 3. Set Up Support Email

The documents reference `support@biblechallenge.app`. Make sure this email:
- Is active and monitored
- Can receive customer inquiries
- Has auto-reply set up (recommended)

### 4. Review and Customize

Before publishing:
- Review the legal text to ensure it accurately describes your app
- Consult with a legal professional if needed
- Update the "Last Updated" date if you make changes

## Quick Hosting with GitHub Pages

1. Create a new GitHub repository (e.g., `biblechallenge-legal`)
2. Upload these HTML files to the repository
3. Go to Settings → Pages
4. Enable GitHub Pages from the main branch
5. Your URLs will be: `https://YOUR-USERNAME.github.io/biblechallenge-legal/privacy-policy.html`

## App Store Connect Requirements

When submitting to App Store Connect, you'll need:
- Privacy Policy URL (required)
- Support URL (your website or email)
- Marketing URL (optional)

The Privacy Policy must be accessible without requiring login.
