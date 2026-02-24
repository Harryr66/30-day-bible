# Pre-Launch Checklist

## 1. GitHub Pages Setup (for Legal Docs)

```bash
# Create a new repo on GitHub called 'bible-challenge'
# Then in your project folder:
cd "/Users/harry/Desktop/30 Day Bible Challange"
git remote add origin https://github.com/Harryr66/bible-challenge.git
git push -u origin main
```

Then in GitHub:
1. Go to repo Settings → Pages
2. Source: Deploy from branch
3. Branch: main, folder: /docs
4. Save

Your URLs will be:
- https://Harryr66.github.io/bible-challenge/privacy.html
- https://Harryr66.github.io/bible-challenge/terms.html

## 2. Update App URLs

After GitHub Pages is live, update these files:
- `30DayBibleChallenge/Views/Premium/PaywallView.swift` (lines 326, 329)
- `30DayBibleChallenge/App/ContentView.swift` (line 447)

Replace `example.com` with your GitHub Pages URLs.

## 3. Xcode Setup

1. Open project in Xcode
2. Select project → Signing & Capabilities
3. Set Team to your Apple Developer account
4. Verify Bundle Identifier: `com.biblechallenge.app`

## 4. App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Create new app:
   - Platform: iOS
   - Name: Bible Challenge - Daily Scripture
   - Primary Language: English
   - Bundle ID: com.biblechallenge.app
   - SKU: biblechallenge2024

3. Fill in App Information:
   - Copy from `AppStore/description.txt`
   - Category: Education
   - Age Rating: 4+

4. Create In-App Purchases:
   - Go to Features → In-App Purchases
   - Create subscription group "Premium"
   - Add Monthly ($9.99/month)
   - Add Lifetime ($49.99 one-time, Non-Consumable)

## 5. Screenshots

1. Run app in simulators (see screenshots-guide.md)
2. Capture screens: Cmd + S
3. Add text overlays if desired
4. Upload to App Store Connect

Required devices:
- iPhone 6.7" (iPhone 15 Pro Max)
- iPhone 6.5" (iPhone 11 Pro Max)
- iPhone 5.5" (iPhone 8 Plus)

## 6. Build & Submit

```bash
# In Xcode:
1. Product → Archive
2. Distribute App → App Store Connect
3. Upload
```

## 7. Submit for Review

1. In App Store Connect, select your build
2. Answer export compliance (No encryption = No)
3. Submit for Review

---

## Files Created

| File | Purpose |
|------|---------|
| `docs/index.html` | GitHub Pages landing page |
| `docs/privacy.html` | Privacy Policy |
| `docs/terms.html` | Terms of Service |
| `AppStore/description.txt` | App Store listing copy |
| `AppStore/screenshots-guide.md` | Screenshot instructions |
| `AppStore/PRE-LAUNCH-CHECKLIST.md` | This checklist |

---

## Status

- [x] isPremium set to false
- [x] App icons created
- [x] Privacy manifest
- [x] Legal docs (HTML)
- [x] GitHub Pages folder ready
- [x] App Store description
- [x] 90+ lessons
- [x] 200+ quiz questions
- [ ] Set Development Team in Xcode
- [ ] Create GitHub repo & enable Pages
- [ ] Update URLs in code
- [ ] Take screenshots
- [ ] Create App Store Connect listing
- [ ] Create In-App Purchases
- [ ] Archive and upload
- [ ] Submit for review
