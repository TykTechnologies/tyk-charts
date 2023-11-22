{{/*
Expand the name of the chart.
*/}}
{{- define "tyk-dev-portal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-dev-portal.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tyk-dev-portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tyk-dev-portal.labels" -}}
helm.sh/chart: {{ include "tyk-dev-portal.chart" . }}
{{ include "tyk-dev-portal.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tyk-dev-portal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tyk-dev-portal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "tyk-dev-portal.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
    It lists all services in the release namespace and find a service
    for Tyk Dashboard with its label.
*/}}
{{- define "tyk-dev-portal.dashboardSvcName" -}}
   {{- $services := (lookup "v1" "Service" .Release.Namespace "") -}}
   {{- if $services -}}
       {{- range $index, $svc := $services.items -}}
           {{- range $key, $val := $svc.metadata.labels -}}
               {{- if and (eq $key "app") (contains "dashboard-svc-" $val) -}}
{{- $svc.metadata.name | trim -}}
               {{ end }}
           {{- end }}
       {{- end }}
   {{- end }}
{{- end }}

{{- define "tyk-dev-portal.dashboardUrl" -}}
{{- if ne .Values.overrideTykDashUrl "" -}}
    {{ .Values.overrideTykDashUrl }}
{{- else if (include "tyk-dev-portal.dashboardSvcName" .) -}}
http{{ if .Values.global.tls.dashboard }}s{{ end }}://{{ include "tyk-gateway.dashboardSvcName" . }}.{{ .Release.Namespace }}.svc:{{ .Values.global.servicePorts.dashboard }}
{{- else -}}
http{{ if .Values.global.tls.dashboard }}s{{ end }}://dashboard-svc-{{ .Release.Name }}-tyk-dashboard.{{ .Release.Namespace }}.svc:{{ .Values.global.servicePorts.dashboard }}
{{- end -}}
{{- end -}}