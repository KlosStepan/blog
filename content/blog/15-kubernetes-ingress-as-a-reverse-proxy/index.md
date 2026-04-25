---
title: "Kubernetes Ingress as a Reverse Proxy"
date: "2026-03-25T10:00:00.000Z"
---

**Reverse proxy** — a single HTTP(S) entry point that accepts external requests and forwards them to one or more backend servers, handling TLS termination, load balancing, routing and cross-cutting concerns (auth, caching).

**Kubernetes** — a container orchestration system that runs in cloud and schedules Pods from declarative resources (Deployments, Services, ConfigMaps), providing service discovery, scaling and self‑healing.

**Ingress** — a Kubernetes API object that declares hostname/path → Service routing rules; an Ingress Controller (nginx/Traefik/Envoy) implements those rules and acts as the cluster’s reverse proxy.


## Why you might encounter this problem  

I recently run into an issue with my web application setup. I host most of my static / frontend content in Kubernetes - with wired in ci/cd that allows me to easily build and deploy from GitHub `main` branch of project. If backend is hosted elsewhere, you will more or less likely (allowlist of foreign adresses might alleviate to some extent) run into CORS issues. That issue was implementation of SSO via Google - which needs to be implemented both into `frontend` and `backend` sharing same address is strictly enforced by Google's policy.

## Specific setup that needs fix

As mentioned, initial setup had to be reworked to work smoothly. It does not, as a result of strict CORS policy.

![Kubernetes+VPS Google SSO - bad](./k8s-vps-google-sso-bad.png)

## Fixed setup, masking under /api

We mask `external domain` under  `projectdomain.com/api`. New setup that we need to achieve.

![Kubernetes+VPS Google SSO - good](./k8s-vps-google-sso-good.png)


## Practical split: Ingress + /api Ingress

Traffic is split into two Ingress resources so the cluster cleanly handles frontend routing and `/api` proxying on the same domain.

### High level
- **Primary Ingress** (`johndoe-kubernetes-ingress-config.yaml`)  
  Terminates TLS and routes `projectdomain.com` → `project-frontend-service`.
- **API Ingress** (`johndoe-projectdomain-com-api.yaml`)  
  Handles `https://projectdomain.com/api`, rewrites the path, sets `Host: project-domain.com`, and proxies to the external backend over HTTPS (targeted via a Kubernetes Service).

---

## Files to create/apply
- [johndoe-kubernetes-ingress-config.yaml](johndoe-kubernetes-ingress-config.yaml)  
- [johndoe-projectdomain-com-api.yaml](johndoe-projectdomain-com-api.yaml)

---

## Apply
```sh
kubectl apply -f johndoe-kubernetes-ingress-config.yaml
kubectl apply -f johndoe-projectdomain-com-api.yaml
```

Verify
```sh
kubectl get ingress johndoe-kubernetes-ingress johndoe-projectdomain-api -o wide
kubectl describe ingress johndoe-projectdomain-api
```

### Notes
- Both Ingresses use the same host: `projectdomain.com`.
- `/api` is handled separately to avoid conflicts with frontend routing.
- `nginx.ingress.kubernetes.io/upstream-vhost: "project-domain.com"` ensures the correct Host header for the external backend.
- Ensure TLS secret `projectdomain-com-tls` exists (cert-manager or pre-created secret).

### Snippets

1) Primary Ingress (frontend) — host rule excerpt
```yaml
# ...
# host rule inside johndoe-kubernetes-ingress-config.yaml
- host: "projectdomain.com"
  http:
    paths:
      - path: "/"
        pathType: Prefix
        backend:
          service:
            name: project-frontend-service
            port:
              number: 80
# ...
```

2) API Ingress (full) — `johndoe-projectdomain-com-api.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: johndoe-projectdomain-api
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/upstream-vhost: "project-domain.com"
    nginx.ingress.kubernetes.io/proxy-body-size: "20m"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - projectdomain.com
      secretName: projectdomain-com-tls
  rules:
    - host: projectdomain.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: project-backend-external
                port:
                  number: 443
```

## Conclusion

This kind of origin mismatch is common and easily solved with a small routing layer: expose the external backend under a path (for example /api) through an Ingress so the frontend and backend share a single origin for SSO and other cookies, avoiding CORS. Using an Ingress controller to handle TLS termination, path‑based routing and header rewrites is an elegant, pragmatic composition of existing primitives.

The trade‑offs are minor — a few extra routing rules, consideration for health checks or sticky sessions, and clear mapping of upstreams — while the benefits (single origin for auth, simpler client code, centralized TLS and observability) make the approach robust and low‑friction.
