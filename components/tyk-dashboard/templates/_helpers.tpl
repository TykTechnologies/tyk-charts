{{- /*
Expand the name of the chart.
*/}}
{{- define "tyk-dashboard.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
ok
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-dashboard.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /*
Create chart name and version as used by the chart label.
*/}}
{{- define "tyk-dashboard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tyk-dashboard.gwproto" -}}
{{- if .Values.global.gateway.tls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.dash_proto" -}}
{{- if .Values.dashboard.tls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.dash_url" -}}
{{ include "tyk-dashboard.dash_proto" . }}://dashboard-svc-{{.Release.Name}}-tyk-dashboard.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.dashboard.containerPort }}
{{- end -}}

{{- define "tyk-dashboard.gateway_host" -}}
{{ include "tyk-dashboard.gwproto" . }}://gateway-svc-{{.Release.Name}}-tyk-gateway.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}

{{- define "tyk-dashboard.gateway_url" -}}
{{ include "tyk-dashboard.gwproto" . }}://gateway-svc-{{.Release.Name}}-tyk-gateway.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.global.gateway.port }}
{{- end -}}

{{- define "tyk-dashboard.redis_url" -}}
{{- if .Values.global.redis.addrs -}}
{{ join "," .Values.global.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.mongo_url" -}}
{{- if .Values.global.mongo.mongoURL -}}
{{ .Values.global.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc.cluster.local:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.pg_connection_string" -}}
{{- if .Values.global.postgres -}}
{{- range $key, $value := .Values.global.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.backend" -}}
{{- if .Values.global.backend -}}
{{- if eq "postgres" .Values.global.backend -}}
postgres
{{- else if eq "mongo" .Values.global.backend -}}
mongo
{{- end -}}
{{- else -}}
mongo
{{- end -}}
{{- end -}}
