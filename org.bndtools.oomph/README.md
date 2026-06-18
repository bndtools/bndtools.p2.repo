# Oomph Bndtools Extension

This repository provides an Eclipse Oomph extension that adds a custom setup task type (`org.bndtools.import`) and publishes it via a p2 update site.

## Modules

- `org.bndtools.oomph.target`: target platform (JRE-17 only)
- `org.bndtools.oomph.import`: Eclipse plugin containing `BndWorkspaceImportTask`
- `org.bndtools.oomph.import.feature`: installable feature wrapping the plugin
- `org.bndtools.oomph.import.site`: P2 update site repository

## Build

Using the Maven wrapper (recommended, no Maven installation required):

```bash
./mvnw clean verify
```

**Build time**: ~3 seconds  
**Output**: P2 repository at `org.bndtools.oomph.import.site/target/repository/`

The generated artifacts include:
- `plugins/org.bndtools.oomph.import_*.jar` - Compiled plugin bundle
- `features/org.bndtools.oomph.import.feature_*.jar` - Feature package
- `content.xml.xz` & `artifacts.xml.xz` - P2 metadata
- `org.bndtools.oomph.import.site-*.zip` - Packaged repository

## Installation

1. In Eclipse, open **Help** → **Install New Software**
2. Click **Add** → **Local**
3. Browse to `org.bndtools.oomph.import.site/target/repository/`
4. Select the **Oomph Bndtools Import** feature and complete the wizard

## Usage in Oomph Setup

After installing, use this task in your `.setup` model:

```xml
<setupTask xsi:type="org.bndtools.import"/>
```

The task will execute `bnd workspace init` in the Eclipse workspace during project setup.

## Build Details

- **Tycho Version**: 4.0.9
- **Java Target**: JavaSE-17
- **No external p2 dependencies** - Builds offline against system JRE only
- **CI/CD**: GitHub Actions workflow included (`.github/workflows/ci.yml`)
