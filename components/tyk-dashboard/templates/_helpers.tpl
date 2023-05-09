{{- /* vim: set filetype=mustache: */}}
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
{{- if .Values.gwTls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.dash_proto" -}}
{{- if .Values.tls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.dash_url" -}}
{{ include "tyk-dashboard.dash_proto" . }}://dashboard-svc-{{ include "tyk-dashboard.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.service.port }}
{{- end -}}

{{- define "tyk-dashboard.gateway_url" -}}
{{ include "tyk-dashboard.gwproto" . }}://gateway-svc-{{ include "tyk-dashboard.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.gateway.service.port }}
{{- end -}}

{{- define "tyk-dashboard.redis_url" -}}
{{- if .Values.redis.addrs -}}
{{ join "," .Values.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.mongo_url" -}}
{{- if .Values.mongo.mongoURL -}}
{{ .Values.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc.cluster.local:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.pg_connection_string" -}}
{{- if .Values.postgres -}}
{{- range $key, $value := .Values.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.backend" -}}
{{- if .Values.backend -}}
{{- if eq "postgres" .Values.backend -}}
postgres
{{- else if eq "mongo" .Values.backend -}}
mongo
{{- end -}}
{{- else -}}
mongo
{{- end -}}
{{- end -}}
