{ config, pkgs, lib, ... }:
{

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.go-neb = {
    # secretFile = "";
    baseUrl = "http://stats1.ffrn.de:4050";
    enable = true;
    secretFile = "${config.age.secrets."go-neb".path}";
    config = {
      clients = [
        {
          UserID = "@ffrn-mon:matrix.org";
          AccessToken = "$ACCESSTOKEN";
          DeviceID = "$DEVICEID";
          HomeserverURL = "https://matrix-client.matrix.org";
          Sync = true;
          AutoJoinRooms = true;
          DisplayName = "ffrn-mon";
          AcceptVerificationFromUsers = [ ":dragar.de" "^@ffrn-mon:matrix.org$" ":matrix.dragar.de" ":ffrn.de"];
        }
      ];
      services = [
        {
          ID = "CemLnjJAF2JmmQhscQKTMTTnovgPjcVK5974";
          Type = "alertmanager";
          UserID = "@ffrn-mon:matrix.org";
          Config = {
            # This is for information purposes only. It should point to Go-NEB path as follows:
            # `/services/hooks/<base64 encoded service ID>`
            # Where in this case "service ID" is "alertmanager_service"
            # Make sure your BASE_URL can be accessed by the Alertmanager instance!
            webhook_url = "${config.services.go-neb.baseUrl}/services/hooks/Q2VtTG5qSkFGMkptbVFoc2NRS1RNVFRub3ZnUGpjVks1OTc0";
            # Each room will get the notification with the alert rendered with the given template
            rooms = {
              "!GbKOGANVDTklQolXEV:matrix.org" = {
                # text_template = "{{range .Alerts -}} [{{ .Status }}] {{index .Labels \"alertname\" }}: {{index .Annotations \"summary\"}} {{ end -}}";
                # html_template = "{{range .Alerts -}} {{ $$severity := index .Labels \"severity\" }}    {{ if eq .Status \"firing\" }}      {{ if eq $$severity \"critical\"}}        <font color='red'><b>[FIRING - CRITICAL]</b></font>      {{ else if eq $$severity \"warning\"}}        <font color='orange'><b>[FIRING - WARNING]</b></font>      {{ else }}        <b>[FIRING - {{ $$severity }}]</b>      {{ end }}    {{ else }}      <font color='green'><b>[RESOLVED]</b></font>    {{ end }}  {{ index .Labels \"alertname\"}}: {{ index .Annotations \"summary\"}}   (<a href=\"{{ .GeneratorURL }}\">source</a>)<br/>{{end -}}";
                text_template = ''
                  {{range .Alerts -}}
                    {{- $$severity := index .Labels "severity" -}}
                    {{- if eq .Status "firing" -}}
                      {{- if eq $$severity "page" -}}         [!CRITICAL!]
                      {{- else if eq $$severity "critical" -}}[CRITICAL]
                      {{- else if eq $$severity "warning" -}} [WARNING]
                      {{- else if eq $$severity "info" -}}    [INFO]
                      {{- else -}}                           [{{ if $$severity }}{{ $$severity }}{{ else }}FIRING{{ end }}]
                      {{- end -}}
                    {{- else -}}                             [RESOLVED]
                    {{- end }} {{ index .Labels "alertname" -}}
                    {{- if index .Annotations "description" -}}: {{ index .Annotations "description" -}}{{- end }}
                  {{ end -}}'';
                html_template = ''
                  {{range .Alerts -}}
                    {{- $$severity := index .Labels "severity" -}}
                    {{- if eq .Status "firing" -}}
                      {{- if eq $$severity "page" -}}         <font data-mx-color="#ffffff" data-mx-bg-color="#ff0000"><b>[CRITICAL]</b></font>
                      {{- else if eq $$severity "critical" -}}<font data-mx-color="#ff0000"><b>[CRITICAL]</b></font>
                      {{- else if eq $$severity "warning" -}} <font data-mx-color="#ffa500"><b>[WARNING]</b></font>
                      {{- else if eq $$severity "info" -}}    <font data-mx-color="#17a2b8"><b>[INFO]</b></font>
                      {{- else -}}                           <b>[{{ if $$severity }}{{ $$severity }}{{ else }}FIRING{{ end }}]</b>
                      {{- end -}}
                    {{- else -}}                             <font data-mx-color="#008000"><b>[RESOLVED]</b></font>
                    {{- end }} {{ index .Labels "alertname" -}}
                    {{- if index .Annotations "description" -}}: {{ index .Annotations "description" -}}{{- end -}}
                    {{-  if .GeneratorURL }} (<a href="{{ .GeneratorURL }}">source</a>)<br/>{{- end }}
                  {{ end -}}'';
                msg_type = "m.text";  # Must be either `m.text` or `m.notice`
              };
            };
          };
        }
        {
          ID =  "echo";
          Type = "echo";
          UserID = "@ffrn-mon:matrix.org";
          Config = {};
        }
      ];
    };
  };

  age.secrets."go-neb" = {
    file = ../secrets/stats1/go-neb.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };
}