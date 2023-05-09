{{- /* vim: set filetype=mustache: */}}
{{- /*
Expand the name of the chart.
*/}}
{{- define "tyk-bootstrap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
ok
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-bootstrap.fullname" -}}
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
ok
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-gateway.fullname" -}}
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
{{- define "tyk-bootstrap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tyk-bootstrap.gwproto" -}}
{{- if .Values.gwTls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.dash_proto" -}}
{{- if .Values.tls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.dash_url" -}}
{{ include "tyk-bootstrap.dash_proto" . }}://dashboard-svc-tyk-dashboard.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.dashboard.service.port }}
{{- end -}}

{{- define "tyk-bootstrap.gateway_url" -}}
{{ include "tyk-bootstrap.gwproto" . }}://gateway-svc-tyk-gateway.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.gateway.service.port }}
{{- end -}}

{{- define "tyk-bootstrap.redis_url" -}}
{{- if .Values.redis.addrs -}}
{{ join "," .Values.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.mongo_url" -}}
{{- if .Values.mongo.mongoURL -}}
{{ .Values.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc.cluster.local:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.pg_connection_string" -}}
{{- if .Values.postgres -}}
{{- range $key, $value := .Values.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-bootstrap.backend" -}}
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
