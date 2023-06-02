{{- /*
Expand the name of the chart.
*/}}
{{- define "tyk-bootstrap.name" -}}
{{- default .Chart.Name .Values.bootstrap.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
ok
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-bootstrap.fullname" -}}
{{- if .Values.bootstrap.fullnameOverride -}}
{{- .Values.bootstrap.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.bootstrap.nameOverride -}}
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
{{- define "tyk-bootstrap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tyk-bootstrap.gwproto" -}}
{{- if .Values.global.tls.gateway -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.dash_proto" -}}
{{- if .Values.global.tls.dashboard -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.dash_url" -}}
{{ include "tyk-bootstrap.dash_proto" . }}://dashboard-svc-{{.Release.Name}}-tyk-dashboard.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.bootstrap.dashboard.service.port }}
{{- end -}}

{{- define "tyk-bootstrap.gateway_url" -}}
{{ include "tyk-bootstrap.gwproto" . }}://gateway-svc-{{.Release.Name}}-tyk-gateway.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.bootstrap.gateway.service.port }}
{{- end -}}

{{- define "tyk-bootstrap.redis_url" -}}
{{- if .Values.global.redis.addrs -}}
{{ join "," .Values.global.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.mongo_url" -}}
{{- if .Values.global.mongo.mongoURL -}}
{{ .Values.global.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc.cluster.local:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.pg_connection_string" -}}
{{- if .Values.global.postgres -}}
{{- range $key, $value := .Values.global.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.backend" -}}
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
