# Writer's Empire

The GitHub Pages site is the game itself. There is no README landing page.

## Gameplay

**WRITE → UPGRADE → GO TO [next location] → GET A MUSE → start faster**

- One-screen gameplay.
- Six upgrades are always visible in a 2×3 grid.
- `GO TO [next location]` appears only when its word requirement is met.
- `GET A MUSE` appears only after 1,000,000 words.
- Each Muse gives +5% permanent production.
- Save/load and offline production.

## Local run

```bash
flutter pub get
flutter run -d chrome
```

## GitHub Pages

Build the web app:

```bash
flutter build web --release --base-href "/writers_empire/"
```

Publish the generated `build/web` directory as the GitHub Pages artifact.
