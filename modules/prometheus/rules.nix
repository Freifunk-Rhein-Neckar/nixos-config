{ lib, pkgs, config, ... }:
{
  services.prometheus.rules = [
    (builtins.toJSON {
      groups = [
        {
          name = "aggregate";
          rules = [
            {
              alert = "MachineDown";
              expr = "avg without (job) (probe_success{job=~\"icmp(4|6)\"}) < 0.5";
              for = "2m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "A Machine is down";
                description = "Machine {{ $labels.instance }} is down";
              };
            }
          ];
        }
        {
          name = "blackbox";
          rules = [
            {
              alert = "Icmp4Timeout";
              expr = "probe_success{job=~\"icmp4(_extra)?\"} == 0";
              for = "5m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "ICMP requests to the primary IPv4 address timed out";
                description = "{{ $labels.instance }} does not respond to ICMPv4 echo requests";
              };
            }
            {
              alert = "Icmp6Timeout";
              expr = "probe_success{job=~\"icmp6(_extra)?\"} == 0";
              for = "5m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "ICMP requests to the primary IPv6 address timed out";
                description = "{{ $labels.instance }} does not respond to ICMPv6 echo requests";
              };
            }
            {
              alert = "DNSSOAError";
              expr = "probe_success{job=~\"dns_soa(_extra)?\"} == 0";
              for = "5m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "SOA response for ffrn.de failed";
                description = "{{ $labels.instance }} failed SOA response for ffrn.de";
              };
            }
            {
              alert = "DNSResolverUDPError";
              expr = "probe_success{job=~\"dns_udp(_extra)?\"} == 0";
              for = "5m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "Resolving youtube.com failed when queried via UDP";
                description = "{{ $labels.instance }} failed to resolve youtube.com when queried via UDP";
              };
            }
            {
              alert = "DNSResolverTCPError";
              expr = "probe_success{job=~\"dns_tcp(_extra)?\"} == 0";
              for = "5m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "Resolving youtube.com failed when queried via TCP";
                description = "{{ $labels.instance }} failed to resolve youtube.com when queried via TCP";
              };
            }
            {
              alert = "BlackboxSslCertificateWillExpireSoon";
              expr = "((probe_ssl_earliest_cert_expiry - time())/86400) < 20";
              for = "1m";
              labels = {
                severity = "info";
              };
              annotations = {
                summary = "SSL certificate will expire soon";
                description = "SSL certificate for {{ $labels.instance }} expires in {{ $value | printf \"%.0f\"  }} days";
              };
            }
            # https://awesome-prometheus-alerts.grep.to/rules
            {
              alert = "BlackboxSslCertificateWillExpireVerySoon";
              expr = "((probe_ssl_earliest_cert_expiry - time())/86400) < 3";
              for = "1m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "SSL certificate will very expire in less then three days";
                description = "SSL certificate for {{ $labels.instance }} expires in {{ $value | printf \"%.0f\"  }} days";
              };
            }
            {
              alert = "BlackboxSslCertificateExpired";
              expr = "probe_ssl_earliest_cert_expiry - time() <= 0";
              for = "0m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "SSL certificate has expired";
                description = "SSL certificate expired (instance {{ $labels.instance }})";
              };
            }
            {
              alert = "httpStatusCode200";
              expr = "probe_http_status_code != 200";
              for = "5m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "HTTP Status Code is not 200";
                description = "HTTP Status Code is {{ $value }} for {{ $labels.instance }}";
              };
            }
          ];
        }
        {
          name = "isc-kea";
          rules = [
            {
              alert = "DHCPPoolExtremeUsage";
              expr = "round(sum(kea_dhcp4_addresses_assigned_total{}/kea_dhcp4_addresses_total{}) by (instance,subnet)*100,0.1) > 85";
              for = "1m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "A DHCP pool is experiencing more then 85% usage";
                description = "The DHCP pool for {{ $labels.subnet }} is utiziled to {{ $value }}% on {{ $labels.instance }}";
                value = "{{ $value }}";
              };
            }
            {
              alert = "DHCPPoolHighUsage";
              expr = "round(sum(kea_dhcp4_addresses_assigned_total{}/kea_dhcp4_addresses_total{}) by (instance,subnet)*100,0.1) > 65";
              for = "1m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "A DHCP pool is experiencing more then 65% usage";
                description = "The DHCP pool for {{ $labels.subnet }} on {{ $labels.instance }} is utiziled to {{ $value }}%";
              };
            }
          ];
        }
        {
          name = "fastd";
          rules = [
            {
              alert = "FastdPeerNumber";
              expr = "fastd_peers_up_total >= 121";
              for = "1m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "number of fastd peers is high";
                description = "{{ $value }} fastd peers on {{ $labels.interface }}";
                value = "{{ $value }}";
              };
            }
            {
              alert = "FastdPeerInterfaceNotUp";
              expr = "fastd_peer_info{fastd_instance=~\"dom0.*\"} unless on(interface) label_join(node_network_carrier{device=~\"dom0p.*\"}, \"interface\", \"\", \"device\")";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                description = "A fastd peer link is not up";
                summary = "Link {{ $labels.interface }} on {{ $labels.instance }} is down";
              };
            }
          ];
        }
        {
          name = "main";
          rules = [
            {
              alert = "ExportedMetricsDown";
              expr = "up{job!~\"snmp_.*\"} == 0";
              for = "5m";
              annotations = {
                summary = "A Exporter is down";
                description = "The exporter {{ $labels.instance }} is down for more than 5 minutes";
              };
            }
            {
              alert = "ExportedMetricsDownSNMP";
              expr = "up{job=~\"snmp_.*\"} == 0";
              for = "24h";
              annotations = {
                summary = "SNMP Device is not reachable for 24 Hours";
                description = "An SNMP target is not reachable for more than 24 Hours ({{ $labels.instance }})";
              };
            }
          ];
        }
        {
          name = "node";
          rules = [
            {
              alert = "InstanceHighCpu";
              expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\", instance!~\"master..*\"}[5m])) BY (instance) * 100) > 90";
              for = "5m";
              labels = {
                severity = "info";
              };
              annotations = {
                summary = "CPU usage above 90% for more than 5m";
                description = "Instance {{ $labels.instance }}: cpu usage at {{ $value | printf \"%.2f\" }}";
                value = "{{ $value }}";
              };
            }
            {
              alert = "InstanceHighCpuLong";
              expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) BY (instance) * 100) > 90";
              for = "30m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "CPU usage above 90% for more than 30m";
                description = "Instance {{ $labels.instance }}: persistent cpu usage at {{ $value | printf \"%.2f\" }} for 30m";
                value = "{{ $value }}";
              };
            }
            {
              alert = "InstanceHighCpuExtremeLong";
              expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) BY (instance) * 100) > 90";
              for = "90m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "CPU usage above 90% for more than 90m";
                description = "Instance {{ $labels.instance }}: persistent cpu usage at {{ $value | printf \"%.2f\" }} for 90m";
                value = "{{ $value }}";
              };
            }
            {
              alert = "InstanceLowMem";
              expr = "node_memory_MemAvailable_bytes / 1024 / 1024 < node_memory_MemTotal_bytes / 1024 / 1024 / 10";
              for = "3m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "Less than 10% of free memory";
                description = "Instance {{ $labels.instance }}: {{ $value | printf \"%.2f\" }}MB of free memory";
                value = "{{ $value }}";
              };
            }
            {
              alert = "HostOutOfInodes";
              expr = "node_filesystem_files_free{mountpoint =\"/rootfs\"} / node_filesystem_files{mountpoint=\"/rootfs\"} * 100 < 10 and ON (instance, device, mountpoint) node_filesystem_readonly{mountpoint=\"/rootfs\"} == 0";
              for = "2m";
              labels = {
                severity = "warning";
              };
              annotations = {
                description = "Host almost out of inodes";
                summary = "Disk is almost running out of available inodes (< 10% left)\n  VALUE = {{ $value | printf \"%.2f\" }}\n  LABELS: {{ $labels }}";
              };
            }
            {
              alert = "InstanceLowDiskPrediction4Hours";
              expr = "predict_linear(node_filesystem_free_bytes{device=~\"/dev/.*\",job=\"node\",instance!~\"www1.*\"}[1h], 4 * 3600) < 0";
              for = "60m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "Disk will be full in less than 4 hours";
                description = "Instance {{ $labels.instance }}: Disk {{ $labels.mountpoint }} ({{ $labels.device }}) will be full in less than 4 hours";
              };
            }
            {
              alert = "InstanceLowDiskPrediction12Hours";
              expr = "predict_linear(node_filesystem_free_bytes{device=~\"/dev/.*\",job=\"node\",instance!~\"www1.*\"}[3h], 12 * 3600) < 0";
              for = "120m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Disk {{ $labels.mountpoint }} ({{ $labels.device }}) will be full in less than 12 hours";
                description = "Instance {{ $labels.instance }}: Disk {{ $labels.mountpoint }} ({{ $labels.device }}) will be full in less than 12 hours";
              };
            }
            {
              alert = "InstanceLowDiskAbs";
              expr = "node_filesystem_avail_bytes{mountpoint=\"/\"} / 1024 / 1024 < 1024";
              for = "1m";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "Less than 1 GB of free disk space left on the root filesystem";
                description = "{{ $labels.instance }}: {{ $value | printf \"%.2f\" }}MB free disk space on {{ $labels.device }}";
                value = "{{ $value }}";
              };
            }
            {
              alert = "InstanceLowDiskPercentage";
              expr = "100 * (node_filesystem_free_bytes / node_filesystem_size_bytes) < 5";
              for = "1m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Less than 5% of free disk space left on a device";
                description = "{{ $labels.instance }}: {{ $value | printf \"%.2f\" }}% free disk space on {{ $labels.device }}";
                value = "{{ $value }}";
              };
            }
            {
              alert = "RaidResync";
              expr = "round((node_md_blocks_synced / node_md_blocks) * 100,0.01) < 100";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "An md-raid device is not in sync";
                description = "Instance {{ $labels.instance }}: {{ $labels.device }} is at {{ $value | printf \"%.2f\" }}% sync";
                value = "{{ $value }}";
              };
            }
            {
              alert = "BondMissingSlave";
              expr = "node_net_bonding_slaves_active < node_net_bonding_slaves";
              labels = {
                severity = "page";
              };
              annotations = {
                summary = "A bond device is missing one or more of its slave interfaces.";
                description = "Instance {{ $labels.instance }}: {{ $labels.master }} missing {{ $value }} slave interface(s)";
                value = "{{ $value }}";
              };
            }
            {
              alert = "SystemdService";
              expr = "node_systemd_unit_state{state=\"failed\",name!~\"one-context.service|borgmatic.service|fastd-peergroup-nodes.service\"} == 1";
              for = "0m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "systemd service {{ $labels.state }}";
                description = "{{ $labels.name }} {{ $labels.state }} on {{ $labels.instance }}";
              };
            }
            {
              alert = "FastdKeySyncService";
              expr = "node_systemd_unit_state{state=\"failed\",name=\"fastd-peergroup-nodes.service\"} == 1";
              for = "20m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "systemd service {{ $labels.name }} has {{ $labels.state }}";
                description = "{{ $labels.name }} {{ $labels.state }} on {{ $labels.instance }}";
              };
            }
            {
              alert = "BackupService";
              expr = "node_systemd_unit_state{state=\"failed\",name=\"borgmatic.service\"} == 1";
              for = "10m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "systemd service {{ $labels.name }} has {{ $labels.state }}";
                description = "{{ $labels.name }} {{ $labels.state }} on {{ $labels.instance }}";
              };
            }
            {
              alert = "ServiceFlapping";
              expr = "changes(node_systemd_unit_state{state=\"failed\"}[5m]) > 5 or\n  (changes(node_systemd_unit_state{state=\"failed\"}[1h]) > 15 unless changes(node_systemd_unit_state{state=\"failed\"}[30m]) < 7)";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "A systemd service changed its state more than 5x/5min or 15x/1h";
                description = "{{ $labels.instance }}: Service {{ $labels.name }} is flapping";
                value = "{{ $labels.name }}";
              };
            }
            {
              alert = "AptUpdateRequired";
              expr = "apt_upgrades_pending{origin!=\"dl.packager.io\"} > 0";
              for = "30m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "A machine has updates, please run pkg.upgrade";
                description = "{{ $labels.instance }}: {{ $value }} update(s) available, please run pkg.upgrade";
                value = "{{ $value }}";
              };
            }
            {
              alert = "AptUpdateRequiredZammad";
              expr = "apt_upgrades_pending{origin=\"dl.packager.io\"} > 0";
              for = "30d";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "A machine has new zammad updates, please run pkg.upgrade";
                description = "{{ $labels.instance }}: {{ $value }} zammad update available, please run pkg.upgrade";
                value = "{{ $value }}";
              };
            }
            {
              alert = "MachineRebootRequired";
              expr = "node_reboot_required > 0";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "A machine requires a reboot";
                description = "{{ $labels.instance }}: reboot required";
              };
            }
            {
              alert = "NodeExporterTextfileStale";
              expr = "time() - node_textfile_mtime_seconds{file!=\"gluon-census.prom\"} >= 86400";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Node exporter textfile has gone stale.";
                description = "{{ $labels.instance }}: Node exporter textfile {{ $labels.file }} has gone stale.";
              };
            }
            {
              alert = "HostPhysicalComponentTooHot";
              expr = "node_hwmon_temp_celsius{instance!~\"(itter|weschnitz).*\"} > 75";
              for = "2m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Host physical component too hot (instance {{ $labels.instance }})";
                description = "Physical hardware component ({{ $labels.chip }} - {{ $labels.sensor }}) too hot: {{ $value }} °C";
                value = "{{ $value }}";
              };
            }
            {
              alert = "HostPhysicalComponentTooHotRyzen";
              expr = "node_hwmon_temp_celsius{instance=~\"(itter|weschnitz).*\",sensor!~\"temp[3|4|6]\"} > 75";
              for = "2m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Host physical component too hot (instance {{ $labels.instance }})";
                description = "Physical hardware component ({{ $labels.chip }} - {{ $labels.sensor }}) too hot: {{ $value }} °C";
                value = "{{ $value }}";
              };
            }
            {
              alert = "HostRaidArrayGotInactive";
              expr = "node_md_state{state=\"inactive\"} > 0";
              for = "0m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Host RAID array got inactive (instance {{ $labels.instance }})";
                description = "RAID array {{ $labels.device }} is in degraded state due to one or more disks failures. Number of spare drives is insufficient to fix issue automatically.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}";
              };
            }
            {
              alert = "HostRaidDiskFailure";
              expr = "node_md_disks{state=\"failed\"} > 0";
              for = "2m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Host RAID disk failure (instance {{ $labels.instance }})";
                description = "At least one device in RAID array on {{ $labels.instance }} failed. Array {{ $labels.md_device }} needs attention and possibly a disk swap\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}";
              };
            }
            {
              alert = "HostConntrackLimit";
              expr = "100 * (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 70";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Host conntrack limit nearly reached";
                description = "conntrack limit approached to {{ $value | printf \"%.2f\" }}% on {{ $labels.instance }}";
              };
            }
            {
              alert = "HostNoGigabitConnection";
              expr = "(node_network_speed_bytes{instance=~\"(weschnitz|itter|elsenz).*\",device=~\"(eth0|enp1s0)\"}/125000) <1000";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Hosts main network interface isn't connected with at least a Gigabit link (instance {{ $labels.instance }})";
                description = "{{ $labels.instance }}: {{ $labels.device }} is connected at {{ $value }} Mb/s";
              };
            }
          ];
        }
        {
          name = "synapse";
          rules = [
            {
              record = "synapse_federation_transaction_queue_pendingEdus:total";
              expr = "sum(synapse_federation_transaction_queue_pendingEdus or absent(synapse_federation_transaction_queue_pendingEdus)*0)";
            }
            {
              record = "synapse_federation_transaction_queue_pendingPdus:total";
              expr = "sum(synapse_federation_transaction_queue_pendingPdus or absent(synapse_federation_transaction_queue_pendingPdus)*0)";
            }
            {
              record = "synapse_http_server_request_count:method";
              labels = {
                servlet = "";
              };
              expr = "sum(synapse_http_server_request_count) by (method)";
            }
            {
              record = "synapse_http_server_request_count:servlet";
              labels = {
                method = "";
              };
              expr = "sum(synapse_http_server_request_count) by (servlet)";
            }
            {
              record = "synapse_http_server_request_count:total";
              labels = {
                servlet = "";
              };
              expr = "sum(synapse_http_server_request_count:by_method) by (servlet)";
            }
            {
              record = "synapse_cache:hit_ratio_5m";
              expr = "rate(synapse_util_caches_cache:hits[5m]) / rate(synapse_util_caches_cache:total[5m])";
            }
            {
              record = "synapse_cache:hit_ratio_30s";
              expr = "rate(synapse_util_caches_cache:hits[30s]) / rate(synapse_util_caches_cache:total[30s])";
            }
            {
              record = "synapse_federation_client_sent";
              labels = {
                type = "EDU";
              };
              expr = "synapse_federation_client_sent_edus + 0";
            }
            {
              record = "synapse_federation_client_sent";
              labels = {
                type = "PDU";
              };
              expr = "synapse_federation_client_sent_pdu_destinations:count + 0";
            }
            {
              record = "synapse_federation_client_sent";
              labels = {
                type = "Query";
              };
              expr = "sum(synapse_federation_client_sent_queries) by (job)";
            }
            {
              record = "synapse_federation_server_received";
              labels = {
                type = "EDU";
              };
              expr = "synapse_federation_server_received_edus + 0";
            }
            {
              record = "synapse_federation_server_received";
              labels = {
                type = "PDU";
              };
              expr = "synapse_federation_server_received_pdus + 0";
            }
            {
              record = "synapse_federation_server_received";
              labels = {
                type = "Query";
              };
              expr = "sum(synapse_federation_server_received_queries) by (job)";
            }
            {
              record = "synapse_federation_transaction_queue_pending";
              labels = {
                type = "EDU";
              };
              expr = "synapse_federation_transaction_queue_pending_edus + 0";
            }
            {
              record = "synapse_federation_transaction_queue_pending";
              labels = {
                type = "PDU";
              };
              expr = "synapse_federation_transaction_queue_pending_pdus + 0";
            }
            {
              record = "synapse_storage_events_persisted_by_source_type";
              expr = "sum without(type, origin_type, origin_entity) (synapse_storage_events_persisted_events_sep{origin_type=\"remote\"})";
              labels = {
                type = "remote";
              };
            }
            {
              record = "synapse_storage_events_persisted_by_source_type";
              expr = "sum without(type, origin_type, origin_entity) (synapse_storage_events_persisted_events_sep{origin_entity=\"*client*\",origin_type=\"local\"})";
              labels = {
                type = "local";
              };
            }
            {
              record = "synapse_storage_events_persisted_by_source_type";
              expr = "sum without(type, origin_type, origin_entity) (synapse_storage_events_persisted_events_sep{origin_entity!=\"*client*\",origin_type=\"local\"})";
              labels = {
                type = "bridges";
              };
            }
            {
              record = "synapse_storage_events_persisted_by_event_type";
              expr = "sum without(origin_entity, origin_type) (synapse_storage_events_persisted_events_sep)";
            }
            {
              record = "synapse_storage_events_persisted_by_origin";
              expr = "sum without(type) (synapse_storage_events_persisted_events_sep)";
            }
          ];
        }
      ];
    })
  ];
}
