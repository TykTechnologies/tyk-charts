{{/*
Expand the name of the chart.
*/}}
{{- define "tyk-mdcb.name" -}}
{{- default .Chart.Name .Values.mdcb.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-mdcb.fullname" -}}
{{- if .Values.mdcb.fullnameOverride }}
{{- .Values.mdcb.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.mdcb.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tyk-mdcb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tyk-mdcb.labels" -}}
app: mdcb-{{ include "tyk-mdcb.fullname" . }}
helm.sh/chart: {{ include "tyk-mdcb.chart" . }}
{{ include "tyk-mdcb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tyk-mdcb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tyk-mdcb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tyk-mdcb.serviceAccountName" -}}
{{- if .Values.mdcb.serviceAccount.enabled }}
{{- default (include "tyk-mdcb.fullname" .) .Values.mdcb.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.mdcb.serviceAccount.name }}
{{- end }}
{{- end }}
