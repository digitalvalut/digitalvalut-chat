# 🔧 GitHub Actions Setup Guide

## ⚠️ Important: Add GitHub Actions Workflow

Your repository is almost complete! The GitHub Actions workflow file has been created locally but needs to be added to GitHub. This workflow will automatically build your Android APK and Flutter Web app whenever you push code.

## 📝 Why Manual Setup?

GitHub requires a Personal Access Token with `workflow` scope to create or modify GitHub Actions files. Your current token doesn't have this permission (for security reasons).

---

## 🚀 Option 1: Add Workflow via GitHub Web Interface (Easiest - 2 minutes)

### Step-by-Step:

1. **Go to your repository**:
   - Visit: https://github.com/digitalvalut/digitalvalut-chat

2. **Create the workflow directory**:
   - Click "Add file" → "Create new file"
   - In the filename box, type: `.github/workflows/flutter-ci.yml`
   - GitHub will automatically create the directories

3. **Copy the workflow content**:
   - Open the file: `/home/ubuntu/code_artifacts/digitalvalut_chat/.github/workflows/flutter-ci.yml`
   - Copy all content from that file
   - Paste into the GitHub editor

4. **Commit the file**:
   - Scroll down
   - Commit message: "Add GitHub Actions CI/CD workflow"
   - Click "Commit new file"

5. **Done!** 🎉
   - Go to "Actions" tab to see your first build
   - It will automatically build Android APK and Flutter Web

---

## 🔑 Option 2: Create Token with Workflow Scope (For Git Push)

If you prefer to push the workflow file via git:

### Step-by-Step:

1. **Create new token**:
   - Go to: https://github.com/settings/tokens/new
   - Give it a name: "DigitalValut Workflow Token"
   - Expiration: 90 days (or custom)
   - **Select scopes**:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)
   - Click "Generate token"
   - **Copy the token** (you won't see it again!)

2. **Update git remote**:
   ```bash
   cd /home/ubuntu/code_artifacts/digitalvalut_chat
   
   # Replace YOUR_NEW_TOKEN with the token you just created
   export NEW_TOKEN="YOUR_NEW_TOKEN"
   
   git remote set-url origin https://${NEW_TOKEN}@github.com/digitalvalut/digitalvalut-chat.git
   ```

3. **Commit and push the workflow**:
   ```bash
   git add .github/workflows/flutter-ci.yml
   git commit -m "Add GitHub Actions CI/CD workflow"
   git push origin master
   ```

4. **Done!** The workflow is now on GitHub.

---

## 📦 What the Workflow Does

Once added, the GitHub Actions workflow will:

### On Every Push to Master:
- ✅ **Build Android APK** (Release version)
  - Downloadable from Actions → Artifacts
  - Named: `android-release-apk`
  - Valid for 30 days

- ✅ **Build Flutter Web** (Release version)
  - Downloadable from Actions → Artifacts
  - Named: `flutter-web-build`
  - Ready for Netlify deployment

### Automatic Features:
- 🔍 Code analysis
- 🧪 Automated tests
- 📊 Build status badge in README
- 💾 Artifact storage (30 days)

---

## 🌐 Next Steps After Adding Workflow

1. **Wait for first build** (3-5 minutes):
   - Go to: https://github.com/digitalvalut/digitalvalut-chat/actions
   - Watch the build progress

2. **Download artifacts**:
   - Click on the completed workflow run
   - Scroll down to "Artifacts"
   - Download `android-release-apk` → Install on Android
   - Download `flutter-web-build` → Deploy to Netlify

3. **Deploy to Netlify**:
   - Extract `flutter-web-build.zip`
   - Go to: https://app.netlify.com/drop
   - Drag the `build/web` folder
   - Your app is live! 🎉

---

## 🔧 Troubleshooting

### "Workflow not running"
- Check that the file is at: `.github/workflows/flutter-ci.yml`
- Verify the YAML syntax is correct
- Check Actions tab for errors

### "Build failing"
- Check the build logs in Actions tab
- Most common issues:
  - Missing dependencies in pubspec.yaml
  - Syntax errors in Dart code
  - Test failures

### "Can't download artifacts"
- Artifacts expire after 30 days
- You need to be logged into GitHub
- Re-run the workflow to generate new artifacts

---

## 📚 Additional Resources

- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Flutter CI/CD Guide**: https://docs.flutter.dev/deployment/cd
- **Netlify Deployment**: https://docs.netlify.com/

---

## ✅ Quick Checklist

- [ ] Workflow file added to GitHub
- [ ] First build completed successfully
- [ ] Android APK downloaded and tested
- [ ] Flutter Web deployed to Netlify
- [ ] Build status badge showing in README

Once all steps are complete, your app has full CI/CD automation! 🚀

---

**Questions?** Open an issue at: https://github.com/digitalvalut/digitalvalut-chat/issues
