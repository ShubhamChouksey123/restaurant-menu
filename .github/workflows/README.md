# GitHub Actions Workflows

This directory contains automated workflows for validating, testing, and deploying the restaurant menu.

## Workflows

### 1. Validate Files (`validate.yml`)

**Triggers:** Push to master/main, Pull Requests, Manual

**Purpose:** Comprehensive validation of all project files

**Jobs:**
- **validate-html** - Validates HTML5 syntax and structure
- **validate-images** - Checks all 126 dish images exist and are valid
- **check-links** - Verifies all CSS, JS, and image references
- **lint-css** - Checks CSS code quality with stylelint
- **check-project-structure** - Ensures all required files/directories exist

**Status Badge:**
```markdown
![Validate Files](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml/badge.svg)
```

---

### 2. Deploy to GitHub Pages (`deploy.yml`)

**Triggers:** Push to master/main, Manual

**Purpose:** Automatically deploys the site to GitHub Pages

**Jobs:**
- **build** - Verifies files and prepares for deployment
- **deploy** - Deploys to GitHub Pages

**Requirements:**
- GitHub Pages must be enabled in repository settings
- Use "GitHub Actions" as the source

**Site URL:** https://shubhamchouksey123.github.io/restaurant-menu/

**Status Badge:**
```markdown
![Deploy](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml/badge.svg)
```

---

### 3. Check Links (`link-checker.yml`)

**Triggers:** Weekly (Mondays 9 AM UTC), Push to HTML/MD files, Manual

**Purpose:** Detects broken links in HTML and Markdown files

**Jobs:**
- **check-links** - Scans all links and reports broken ones
- **Create Issue** - Automatically creates GitHub issue if broken links found

**Status Badge:**
```markdown
![Check Links](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml/badge.svg)
```

---

### 4. Code Quality (`code-quality.yml`)

**Triggers:** Push to master/main, Pull Requests, Manual

**Purpose:** Ensures code quality and best practices

**Jobs:**
- **prettier-check** - Verifies code formatting (HTML, CSS, JS)
- **eslint-check** - Lints JavaScript for errors and warnings
- **file-size-check** - Monitors file sizes for performance
- **accessibility-check** - Checks for missing alt text on images

**Status Badge:**
```markdown
![Code Quality](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml/badge.svg)
```

---

## Running Workflows Manually

You can trigger workflows manually from the GitHub Actions tab:

1. Go to: https://github.com/ShubhamChouksey123/restaurant-menu/actions
2. Select the workflow you want to run
3. Click "Run workflow" button
4. Select the branch (usually `master`)
5. Click "Run workflow"

---

## Setting Up GitHub Pages

To enable automatic deployment:

1. Go to repository **Settings**
2. Navigate to **Pages** section (left sidebar)
3. Under **Source**, select:
   - Source: **GitHub Actions**
4. Save and wait for deployment
5. Your site will be available at: https://shubhamchouksey123.github.io/restaurant-menu/

---

## Workflow Status

View all workflow runs: https://github.com/ShubhamChouksey123/restaurant-menu/actions

---

## Badge Setup

Add these badges to your main README.md:

```markdown
[![Validate Files](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml)
[![Deploy](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml)
[![Check Links](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml)
[![Code Quality](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml)
```

---

## Troubleshooting

### Workflow Fails

1. Check the workflow logs in the Actions tab
2. Look for red ❌ marks indicating failures
3. Read error messages for specific issues

### Common Issues

**HTML Validation Fails:**
- Check for unclosed tags
- Verify proper nesting
- Ensure all attributes are quoted

**Image Validation Fails:**
- Verify all 126 images exist
- Check file paths are correct
- Ensure images aren't corrupted

**Link Checker Fails:**
- Check for broken external links
- Verify internal file paths
- Update or remove dead links

**Deployment Fails:**
- Ensure GitHub Pages is enabled
- Check workflow permissions
- Verify all required files exist

---

## Adding New Workflows

To add a new workflow:

1. Create a new `.yml` file in `.github/workflows/`
2. Define triggers, jobs, and steps
3. Commit and push to trigger
4. Monitor in Actions tab

See [GitHub Actions documentation](https://docs.github.com/en/actions) for more details.
