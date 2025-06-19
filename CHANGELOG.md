# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.2.0

- Fix for boat disappearing after leaving it somewhere and coming back later
  - You may now see the boat flash briefly when you approach it from far away
- Added UE4SS script to fix boat sometimes duplicating
  - The boat may freeze for a split second whenever the duplication would have happened but it should recover from there
- Switched the DARK spell effect with LOCK effect instead so the Row spell doesn't break the Night Eye effect
  - The Row spell is now a touch spell and has a lock icon instead of damage fatigue icon
  - (this is needed so the spell does not make a noise or visual effect when cast)
- Reduced the amount of false-positives with collision detection so the boat shouldn't get grounded in water as often
- Increased height boat needs to be to be considered on land so it can be dragged in the water while water-walking

## 0.1.1

- Fix for CTD in June 5th, 2025 Oblivion Remastered 1.1 Update (1.511.102.0)

## 0.1.0

- Initial Release