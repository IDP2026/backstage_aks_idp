# Runbook

## Start

```bash
# Anwendung lokal starten
npm start
# Container-Image bauen
docker build -t ${{ values.repositoryName }}:latest .
# Kubernetes-Manifeste anwenden
kubectl apply -f k8s/

## `src/index.ts`

```bash
cat > packages/app/templates/enterprise-service-onboarding-template/skeleton/src/index.ts <<'EOF'
import http from 'node:http';

const port = Number(process.env.PORT || '${{ values.containerPort }}');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', service: '${{ values.serviceName }}' }));
    return;
  }

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    service: '${{ values.serviceName }}',
    title: '${{ values.serviceTitle }}',
    lifecycle: '${{ values.lifecycle }}'
  }));
});

server.listen(port, () => {
  console.log('${{ values.serviceName }} listening on port ' + port);
});
