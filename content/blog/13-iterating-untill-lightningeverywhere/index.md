---
title: "Lightning-map into Lightning Everywhere"
date: "2025-11-23T10:00:00.000Z"
---

# Lightning-map into Lightning Everywhere

A quick look at the journey of building Lightning-map and how each iteration brought it closer to the vision of "Lightning Everywhere"

## Iteration 1: Prototype (React, Bootstrap, Firebase)
- First working version built with React.js and Bootstrap for UI.
- Firebase used for authentication and Firestore as the database.
- Rounds with merchants performed to gather feedback.
---

## Iteration 2: Design for MVP Rewrite
- Reached out to several graphic designers to improve the look and feel.
- Focused on branding and vision.
- Focused on creating a more user-friendly and visually appealing MVP.
- Cycled through map tools, ended up using 3rd.

---

## Iteration 3: Rewrite to Ditch Firebase
- Migrated backend from Firebase to a custom stack:
  - Go backend for API and business logic.
  - MinIO for object storage (images, assets).
  - MongoDB for merchant and user data.

---

## Iteration 4: Deployment to DigitalOcean Droplet
- Deployed the application to a DigitalOcean Droplet for the first time.
- Set up basic CI/CD and monitoring.
- Installed certificates.
- Frontend deployed to Kubernetes cluster, backend run in Docker compose to DigitalOcean Droplet.
---

## TODO: Iteration 5
- Move to Kubernetes for orchestration.
- Use managed databases (RDS, etc.) for scalability and reliability.
- Further automate deployment.
- Improve UI: grouping of merchants, starting on city of IP/Geolocation API, prerendering and caching of React stuff, maybe RTK Query. 