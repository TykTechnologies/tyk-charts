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
{{ include "tyk-bootstrap.dash_proto" . }}://dashboard-svc-{{.Release.Name}}-tyk-dashboard.{{ .Release.Namespace }}.svc:{{ .Values.global.servicePorts.dashboard }}
{{- end -}}

{{- define "tyk-bootstrap.gateway_url" -}}
{{ include "tyk-bootstrap.gwproto" . }}://gateway-svc-{{.Release.Name}}-tyk-gateway.{{ .Release.Namespace }}.svc:{{ .Values.global.servicePorts.gateway }}
{{- end -}}
