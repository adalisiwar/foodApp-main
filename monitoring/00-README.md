# Grafana Monitoring Setup for Food Delivery App

## Quick Start

### 1. Apply monitoring manifests

```bash
kubectl apply -f monitoring/04-prometheus-configmap.yaml
kubectl apply -f monitoring/01-prometheus-deployment.yaml
kubectl apply -f monitoring/03-grafana-configmaps.yaml
kubectl apply -f monitoring/02-grafana-deployment.yaml
```

### 2. Verify pods are running

```bash
kubectl get pods -n fooddelivery
```

You should see `prometheus-...` and `grafana-...` pods in Running state.

### 3. Access Grafana UI

```bash
kubectl port-forward -n fooddelivery svc/grafana 30300:3000
```

Open browser: http://localhost:30300

- **Username:** admin
- **Password:** admin123

### 4. Access Prometheus UI (optional)

```bash
kubectl port-forward -n fooddelivery svc/prometheus 9090:9090
```

Open browser: http://localhost:9090

---

## How to Create Dashboards & Capture Screenshots for Your Thesis

### Step 1: Verify Prometheus is scraping your services

In Prometheus UI (http://localhost:9090), go to **Status > Targets**.

You should see all your microservices (api-gateway, user-service, restaurant-service, order-service, delivery-service, admin-service, eureka-server) as `UP`.

> **Screenshot to capture for thesis:** Prometheus Targets page showing all services UP.
> Save as: `Images/project/prometheus_targets.png`

---

### Step 2: Create a dashboard for each microservice in Grafana

In Grafana UI (http://localhost:30300):

1. Click **"+" > New Dashboard > Add visualization**
2. Select **Prometheus** as data source
3. Use the queries below for each service

---

### Dashboard: API Gateway

**Query 1 - Request Rate:**
```promql
rate(http_server_requests_seconds_count{job="api-gateway"}[1m])
```

**Query 2 - Error Rate (%)**:
```promql
rate(http_server_requests_seconds_count{job="api-gateway",status=~"5.."}[1m])
/
rate(http_server_requests_seconds_count{job="api-gateway"}[1m])
```

**Query 3 - Average Response Time**:
```promql
rate(http_server_requests_seconds_sum{job="api-gateway"}[1m])
/
rate(http_server_requests_seconds_count{job="api-gateway"}[1m])
```

**Query 4 - JVM Memory Used**:
```promql
jvm_memory_used_bytes{job="api-gateway"}
```

**Query 5 - Active Connections**:
```promql
tomcat_sessions_active_current_sessions{job="api-gateway"}
```

> **Screenshot to capture:** Complete dashboard with all panels.
> Save as: `Images/grafana/grafana_api_gateway.png`

---

### Dashboard: Eureka Server

**Query 1 - Registered Instances**:
```promql
eureka_server_registered_instance_count_total
```

**Query 2 - Heartbeats Received**:
```promql
rate(eureka_server_heartbeats_received_total[1m])
```

**Query 3 - JVM Memory**:
```promql
jvm_memory_used_bytes{job="eureka-server"}
```

**Query 4 - Uptime**:
```promql
process_uptime_seconds{job="eureka-server"}
```

> **Screenshot to capture:** Complete dashboard.
> Save as: `Images/grafana/grafana_eureka.png`

---

### Dashboard: User Service

**Query 1 - Login Rate**:
```promql
rate(http_server_requests_seconds_count{job="user-service",uri="/api/users/auth/login"}[1m])
```

**Query 2 - Request Rate (all endpoints)**:
```promql
rate(http_server_requests_seconds_count{job="user-service"}[1m])
```

**Query 3 - Response Time (p95)**:
```promql
histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{job="user-service"}[1m])) by (le))
```

**Query 4 - JVM Heap Usage**:
```promql
jvm_memory_used_bytes{job="user-service",area="heap"}
```

**Query 5 - Database Connections (HikariCP)**:
```promql
hikaricp_connections_active{job="user-service"}
```

> **Screenshot to capture:** Complete dashboard.
> Save as: `Images/grafana/grafana_user_service.png`

---

### Dashboard: Restaurant Service

**Query 1 - Request Rate**:
```promql
rate(http_server_requests_seconds_count{job="restaurant-service"}[1m])
```

**Query 2 - Error Rate**:
```promql
rate(http_server_requests_seconds_count{job="restaurant-service",status=~"5.."}[1m])
/
rate(http_server_requests_seconds_count{job="restaurant-service"}[1m])
```

**Query 3 - JVM Memory**:
```promql
jvm_memory_used_bytes{job="restaurant-service"}
```

> **Screenshot to capture:** Complete dashboard.
> Save as: `Images/grafana/grafana_restaurant_service.png`

---

### Dashboard: Order Service

**Query 1 - Request Rate**:
```promql
rate(http_server_requests_seconds_count{job="order-service"}[1m])
```

**Query 2 - Order Status (if custom metric exists)**:
```promql
# Example custom metric - add to OrderService if needed:
# orders_total{status="CONFIRMED"}
```

**Query 3 - Response Time p99**:
```promql
histogram_quantile(0.99, sum(rate(http_server_requests_seconds_bucket{job="order-service"}[1m])) by (le))
```

**Query 4 - JVM Memory**:
```promql
jvm_memory_used_bytes{job="order-service"}
```

> **Screenshot to capture:** Complete dashboard.
> Save as: `Images/grafana/grafana_order_service.png`

---

### Dashboard: Delivery Service

**Query 1 - Request Rate**:
```promql
rate(http_server_requests_seconds_count{job="delivery-service"}[1m])
```

**Query 2 - JVM Memory**:
```promql
jvm_memory_used_bytes{job="delivery-service"}
```

**Query 3 - Active Deliveries (if custom metric exists)**:
```promql
# Example:
# deliveries_active_total
```

> **Screenshot to capture:** Complete dashboard.
> Save as: `Images/grafana/grafana_delivery_service.png`

---

### Dashboard: Admin Service

**Query 1 - Request Rate**:
```promql
rate(http_server_requests_seconds_count{job="admin-service"}[1m])
```

**Query 2 - JVM Memory**:
```promql
jvm_memory_used_bytes{job="admin-service"}
```

> **Screenshot to capture:** Complete dashboard.
> Save as: `Images/grafana/grafana_admin_service.png`

---

### Step 3: Create Global Overview Dashboard

Create a new dashboard with panels from ALL services for a platform-wide view:

**Panel 1 - Service Health Matrix**:
Use the "Stat" visualization with query:
```promql
up{namespace="fooddelivery"}
```
Set thresholds: 1 = green, 0 = red

**Panel 2 - Total Request Rate (all services)**:
```promql
sum(rate(http_server_requests_seconds_count{namespace="fooddelivery"}[1m])) by (job)
```

**Panel 3 - Top 5 Slowest Endpoints**:
```promql
topk(5, rate(http_server_requests_seconds_sum[1m]) / rate(http_server_requests_seconds_count[1m]))
```

**Panel 4 - System-wide Error Rate**:
```promql
sum(rate(http_server_requests_seconds_count{status=~"5.."}[1m])) / sum(rate(http_server_requests_seconds_count[1m]))
```

> **Screenshot to capture:** Overview dashboard.
> Save as: `Images/grafana/grafana_global_overview.png`

---

## Screenshot Checklist for Thesis

| Screenshot | Filename | Description |
|------------|----------|-------------|
| ☐ | `Images/project/prometheus_targets.png` | Prometheus UI showing all services UP |
| ☐ | `Images/grafana/grafana_api_gateway.png` | API Gateway dashboard |
| ☐ | `Images/grafana/grafana_eureka.png` | Eureka Server dashboard |
| ☐ | `Images/grafana/grafana_user_service.png` | User Service dashboard |
| ☐ | `Images/grafana/grafana_restaurant_service.png` | Restaurant Service dashboard |
| ☐ | `Images/grafana/grafana_order_service.png` | Order Service dashboard |
| ☐ | `Images/grafana/grafana_delivery_service.png` | Delivery Service dashboard |
| ☐ | `Images/grafana/grafana_admin_service.png` | Admin Service dashboard |
| ☐ | `Images/grafana/grafana_global_overview.png` | Global overview dashboard |

---

## Tips for Nice Screenshots

1. **Use Grafana's light theme** for better print/ thesis readability:
   - Profile > Preferences > UI Theme > Light

2. **Set time range to "Last 5 minutes"** while generating traffic so graphs show activity.

3. **Generate traffic** using the app or Postman to create visible spikes and patterns.

4. **Use full-screen mode** (F11) before capturing to remove browser clutter.

5. **Recommended capture resolution:** 1920x1080 or higher.

---

## Adding Custom Business Metrics (Optional)

You can add project-specific metrics to any service using Micrometer:

```java
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;

// In your service class:
private final Counter orderCounter;

public OrderService(MeterRegistry registry) {
    this.orderCounter = Counter.builder("orders.created.total")
        .description("Total orders created")
        .tag("service", "order-service")
        .register(registry);
}

public void createOrder() {
    // ... business logic ...
    orderCounter.increment();
}
```

These custom metrics will automatically appear in Prometheus and Grafana.

---

## Troubleshooting

### Grafana can't connect to Prometheus

- Check Prometheus is running: `kubectl get pods -n fooddelivery`
- Verify datasource URL in Grafana: Configuration > Data Sources > Prometheus
  - URL should be: `http://prometheus:9090`

### No metrics appearing

- Verify services have `monitoring: enabled` label
- Check Prometheus targets page for errors
- Ensure `micrometer-registry-prometheus` is in pom.xml
- Verify `management.endpoints.web.exposure.include` includes `prometheus`

### Port forwarding not working

- Make sure NodePort services are correctly applied
- Check Windows Firewall isn't blocking localhost ports
- Try using `kubectl port-forward` instead of NodePort

