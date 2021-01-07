#!/bin/bash


my_name=$0


function setup_environment {
  bf=""
  n=""
  ORGANISATION="Technische Universität Berlin"
  URL="http://www.tubit.tu-berlin.de/menue/hilfe_beratung/"
  SUPPORT="tubit@tu-berlin.de"
if [ ! -z "$DISPLAY" ] ; then
  if which zenity 1>/dev/null 2>&1 ; then
    ZENITY=`which zenity`
  elif which kdialog 1>/dev/null 2>&1 ; then
    KDIALOG=`which kdialog`
  else
    if tty > /dev/null 2>&1 ; then
      if  echo $TERM | grep -E -q "xterm|gnome-terminal|lxterminal"  ; then
        bf="[1m";
        n="[0m";
      fi
    else
      find_xterm
      if [ -n "$XT" ] ; then
        $XT -e $my_name
      fi
    fi
  fi
fi
}

function split_line {
echo $1 | awk  -F '\\\\n' 'END {  for(i=1; i <= NF; i++) print $i }'
}

function find_xterm {
terms="xterm aterm wterm lxterminal rxvt gnome-terminal konsole"
for t in $terms
do
  if which $t > /dev/null 2>&1 ; then
  XT=$t
  break
  fi
done
}


function ask {
     T="DFN eduroam CAT"
#  if ! [ -z "$3" ] ; then
#     T="$T: $3"
#  fi
  if [ ! -z $KDIALOG ] ; then
     if $KDIALOG --yesno "${1}\n${2}?" --title "$T" ; then
       return 0
     else
       return 1
     fi
  fi
  if [ ! -z $ZENITY ] ; then
     text=`echo "${1}" | fmt -w60`
     if $ZENITY --no-wrap --question --text="${text}\n${2}?" --title="$T" 2>/dev/null ; then
       return 0
     else
       return 1
     fi
  fi

  yes=J
  no=N
  yes1=`echo $yes | awk '{ print toupper($0) }'`
  no1=`echo $no | awk '{ print toupper($0) }'`

  if [ $3 == "0" ]; then
    def=$yes
  else
    def=$no
  fi

  echo "";
  while true
  do
  split_line "$1"
  read -p "${bf}$2 ${yes}/${no}? [${def}]:$n " answer
  if [ -z "$answer" ] ; then
    answer=${def}
  fi
  answer=`echo $answer | awk '{ print toupper($0) }'`
  case "$answer" in
    ${yes1})
       return 0
       ;;
    ${no1})
       return 1
       ;;
  esac
  done
}

function alert {
  if [ ! -z $KDIALOG ] ; then
     $KDIALOG --sorry "${1}"
     return
  fi
  if [ ! -z $ZENITY ] ; then
     $ZENITY --warning --text="$1" 2>/dev/null
     return
  fi
  echo "$1"

}

function show_info {
  if [ ! -z $KDIALOG ] ; then
     $KDIALOG --msgbox "${1}"
     return
  fi
  if [ ! -z $ZENITY ] ; then
     $ZENITY --info --width=500 --text="$1" 2>/dev/null
     return
  fi
  echo "$1"
}

function confirm_exit {
  if [ ! -z $KDIALOG ] ; then
     if $KDIALOG --yesno "Wirklich beenden?"  ; then
     exit 1
     fi
  fi
  if [ ! -z $ZENITY ] ; then
     if $ZENITY --question --text="Wirklich beenden?" 2>/dev/null ; then
        exit 1
     fi
  fi
}



function prompt_nonempty_string {
  prompt=$2
  if [ ! -z $ZENITY ] ; then
    if [ $1 -eq 0 ] ; then
     H="--hide-text "
    fi
    if ! [ -z "$3" ] ; then
     D="--entry-text=$3"
    fi
  elif [ ! -z $KDIALOG ] ; then
    if [ $1 -eq 0 ] ; then
     H="--password"
    else
     H="--inputbox"
    fi
  fi


  out_s="";
  if [ ! -z $ZENITY ] ; then
    while [ ! "$out_s" ] ; do
      out_s=`$ZENITY --entry --width=300 $H $D --text "$prompt" 2>/dev/null`
      if [ $? -ne 0 ] ; then
        confirm_exit
      fi
    done
  elif [ ! -z $KDIALOG ] ; then
    while [ ! "$out_s" ] ; do
      out_s=`$KDIALOG $H "$prompt" "$3"`
      if [ $? -ne 0 ] ; then
        confirm_exit
      fi
    done  
  else
    while [ ! "$out_s" ] ; do
      read -p "${prompt}: " out_s
    done
  fi
  echo "$out_s";
}

function user_cred {
  PASSWORD="a"
  PASSWORD1="b"

  if ! USER_NAME=`prompt_nonempty_string 1 "Geben Sie ihre Benutzerkennung ein"` ; then
    exit 1
  fi

  while [ "$PASSWORD" != "$PASSWORD1" ]
  do
    if ! PASSWORD=`prompt_nonempty_string 0 "Geben Sie ihr Passwort ein"` ; then
      exit 1
    fi
    if ! PASSWORD1=`prompt_nonempty_string 0 "Wiederholen Sie das Passwort"` ; then
      exit 1
    fi
    if [ "$PASSWORD" != "$PASSWORD1" ] ; then
      alert "Die Passwörter stimmen nicht überein"
    fi
  done
}
setup_environment
show_info "Dieses Installationsprogramm wurde für ${ORGANISATION} hergestellt.\n\nMehr Informationen und Kommentare:\n\nEMAIL: ${SUPPORT}\nWWW: ${URL}\n\nDas Installationsprogramm wurde mit Software vom GEANT Projekt erstellt."
if ! ask "Dieses Installationsprogramm funktioniert nur für Anwender von ${bf}Technische Universität Berlin.${n}" "Weiter" 1 ; then exit; fi
if [ -d $HOME/.cat_installer ] ; then
   if ! ask "Das Verzeichnis $HOME/.cat_installer existiert bereits; einige Dateien darin könnten überschrieben werden." "Weiter" 1 ; then exit; fi
else
  mkdir $HOME/.cat_installer
fi
# save certificates
echo "-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIBJjANBgkqhkiG9w0BAQUFADBxMQswCQYDVQQGEwJERTEc
MBoGA1UEChMTRGV1dHNjaGUgVGVsZWtvbSBBRzEfMB0GA1UECxMWVC1UZWxlU2Vj
IFRydXN0IENlbnRlcjEjMCEGA1UEAxMaRGV1dHNjaGUgVGVsZWtvbSBSb290IENB
IDIwHhcNOTkwNzA5MTIxMTAwWhcNMTkwNzA5MjM1OTAwWjBxMQswCQYDVQQGEwJE
RTEcMBoGA1UEChMTRGV1dHNjaGUgVGVsZWtvbSBBRzEfMB0GA1UECxMWVC1UZWxl
U2VjIFRydXN0IENlbnRlcjEjMCEGA1UEAxMaRGV1dHNjaGUgVGVsZWtvbSBSb290
IENBIDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCrC6M14IspFLEU
ha88EOQ5bzVdSq7d6mGNlUn0b2SjGmBmpKlAIoTZ1KXleJMOaAGtuU1cOs7TuKhC
QN/Po7qCWWqSG6wcmtoIKyUn+WkjR/Hg6yx6m/UTAtB+NHzCnjwAWav12gz1Mjwr
rFDa1sPeg5TKqAyZMg4ISFZbavva4VhYAUlfckE8FQYBjl2tqriTtM2e66foai1S
NNs671x1Udrb8zH57nGYMsRUFUQM+ZtV7a3fGAigo4aKSe5TBY8ZTNXeWHmb0moc
QqvF1afPaA+W5OFhmHZhyJF81j4A4pFQh+GdCuatl9Idxjp9y7zaAzTVjlsB9WoH
txa2bkp/AgMBAAGjQjBAMB0GA1UdDgQWBBQxw3kbuvVT1xfgiXotF2wKsyudMzAP
BgNVHRMECDAGAQH/AgEFMA4GA1UdDwEB/wQEAwIBBjANBgkqhkiG9w0BAQUFAAOC
AQEAlGRZrTlk5ynrE/5aw4sTV8gEJPB0d8Bg42f76Ymmg7+Wgnxu1MM9756Abrsp
tJh6sTtU6zkXR34ajgv8HzFZMQSyzhfzLMdiNlXiItiJVbSYSKpk+tYcNthEeFpa
IzpXl/V6ME+un2pMSyuOoAPjPuCp1NJ70rOo4nI8rZ7/gFnkm0W09juwzTkZmDLl
6iFhkOQxIY40sfcvNUqFENrnijchvllj4PKFiDFT1FQUhXB59C4Gdyd1Lx+4ivn+
xbrYNuSD7Odlt79jWvNGr4GUN9RBjNYj1h7P9WgbRGOiWrqnNVmh5XAFmw4jV5mU
Cm26OWMohpLzGITY+9HPBVZkVw==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIE1TCCA72gAwIBAgIIUE7G9T0RtGQwDQYJKoZIhvcNAQELBQAwcTELMAkGA1UE
BhMCREUxHDAaBgNVBAoTE0RldXRzY2hlIFRlbGVrb20gQUcxHzAdBgNVBAsTFlQt
VGVsZVNlYyBUcnVzdCBDZW50ZXIxIzAhBgNVBAMTGkRldXRzY2hlIFRlbGVrb20g
Um9vdCBDQSAyMB4XDTE0MDcyMjEyMDgyNloXDTE5MDcwOTIzNTkwMFowWjELMAkG
A1UEBhMCREUxEzARBgNVBAoTCkRGTi1WZXJlaW4xEDAOBgNVBAsTB0RGTi1QS0kx
JDAiBgNVBAMTG0RGTi1WZXJlaW4gUENBIEdsb2JhbCAtIEcwMTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAOmbw2eF+Q2u9Y1Uw5ZQNT1i6W5M7ZTXAFuV
InTUIOs0j9bswDEEC5mB4qYU0lKgKCOEi3SJBF5b4OJ4wXjLFssoNTl7LZBF0O2g
AHp8v0oOGwDDhulcKzERewzzgiRDjBw4i2poAJru3E94q9LGE5t2re7eJujvAa90
D8EJovZrzr3TzRQwT/Xl46TIYpuCGgMnMA0CZWBN7dEJIyqWNVgn03bGcbaQHcTt
/zWGfW8zs9sPxRHCioOhlF1Ba9jSEPVM/cpRrNm975KDu9rrixZWVkPP4dUTPaYf
JzDNSVTbyRM0mnF1xWzqpwuY+SGdJ68+ozk5SGqMrcmZ+8MS8r0CAwEAAaOCAYYw
ggGCMA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUSbfGz+g9H3/qRHsTKffxCnA+
3mQwHwYDVR0jBBgwFoAUMcN5G7r1U9cX4Il6LRdsCrMrnTMwEgYDVR0TAQH/BAgw
BgEB/wIBAjBiBgNVHSAEWzBZMBEGDysGAQQBga0hgiwBAQQCAjARBg8rBgEEAYGt
IYIsAQEEAwAwEQYPKwYBBAGBrSGCLAEBBAMBMA8GDSsGAQQBga0hgiwBAQQwDQYL
KwYBBAGBrSGCLB4wPgYDVR0fBDcwNTAzoDGgL4YtaHR0cDovL3BraTAzMzYudGVs
ZXNlYy5kZS9ybC9EVF9ST09UX0NBXzIuY3JsMHgGCCsGAQUFBwEBBGwwajAsBggr
BgEFBQcwAYYgaHR0cDovL29jc3AwMzM2LnRlbGVzZWMuZGUvb2NzcHIwOgYIKwYB
BQUHMAKGLmh0dHA6Ly9wa2kwMzM2LnRlbGVzZWMuZGUvY3J0L0RUX1JPT1RfQ0Ff
Mi5jZXIwDQYJKoZIhvcNAQELBQADggEBAGMgKP2cIYZyvjlGWTkyJbypAZsNzMp9
QZyGbQpuLLMTWXWxM5IbYScW/8Oy1TWC+4QqAUm9ZrtmL7LCBl1uP27jAVpbykNj
XJW24TGnH9UHX03mZYJOMvnDfHpLzU1cdO4h8nUC7FI+0slq05AjbklnNb5/TVak
7Mwvz7ehl6hyPsm8QNZapAg91ryCw7e3Mo6xLI5qbbc1AhnP9TlEWGOnJAAQsLv8
Tq9uLzi7pVdJP9huUG8sl5bcHUaaZYnPrszy5dmfU7M+oS+SqdgLxoQfBMbrHuif
fbV7pQLxJMUkYxE0zFqTICp5iDolQpCpZTt8htMSFSMp/CzazDlbVBc=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFQDCCBCigAwIBAgIHF6QlDDcO1zANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQG
EwJERTETMBEGA1UEChMKREZOLVZlcmVpbjEQMA4GA1UECxMHREZOLVBLSTEkMCIG
A1UEAxMbREZOLVZlcmVpbiBQQ0EgR2xvYmFsIC0gRzAxMB4XDTE0MDUyNzE0NTU1
NloXDTE5MDcwOTIzNTkwMFowZzELMAkGA1UEBhMCREUxJzAlBgNVBAoTHlRlY2hu
aXNjaGUgVW5pdmVyc2l0YWV0IEJlcmxpbjEPMA0GA1UEAxMGVFVCLUNBMR4wHAYJ
KoZIhvcNAQkBFg9jYUBUVS1CZXJsaW4uREUwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQC4AxwkOaesxXoQK7x3BAtuxt1vEJXi6WpgSuwnD2GnKT3KebP7
PKiy3tM/lN9ytWE6v4u1EEW5RgqM3Dz9B0Uk7hkyfbtt730sE+AG+S/aeAysyPjc
YKfGV3mhvTrQL6sVRUVZj4Mx+bwg+RSqyqNJlWGi3S4XcbBwVCgU/R/uf2fnqrLb
u1o2WcI06kwcnwqAh4uNz97JYTcX3gAx570cpv22pO22OcI6HHF5nHqZFbGZpWS4
AzZFbTV5Tl9V/HFpCFIy49xhF6RKBQGaXEk1BzeX4qfhsGGtWCNgzw9uknQZja9p
8xZ8W7GHIEuZOqgWYAMeSLKtNQy2IZY64UYxAgMBAAGjggH8MIIB+DASBgNVHRMB
Af8ECDAGAQH/AgEBMA4GA1UdDwEB/wQEAwIBBjARBgNVHSAECjAIMAYGBFUdIAAw
HQYDVR0OBBYEFCMyQp7+YkJO+07QF5t45+2KjD54MB8GA1UdIwQYMBaAFEm3xs/o
PR9/6kR7Eyn38QpwPt5kMBoGA1UdEQQTMBGBD2NhQFRVLUJlcmxpbi5ERTCBiAYD
VR0fBIGAMH4wPaA7oDmGN2h0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvZ2xvYmFsLXJv
b3QtY2EvcHViL2NybC9jYWNybC5jcmwwPaA7oDmGN2h0dHA6Ly9jZHAyLnBjYS5k
Zm4uZGUvZ2xvYmFsLXJvb3QtY2EvcHViL2NybC9jYWNybC5jcmwwgdcGCCsGAQUF
BwEBBIHKMIHHMDMGCCsGAQUFBzABhidodHRwOi8vb2NzcC5wY2EuZGZuLmRlL09D
U1AtU2VydmVyL09DU1AwRwYIKwYBBQUHMAKGO2h0dHA6Ly9jZHAxLnBjYS5kZm4u
ZGUvZ2xvYmFsLXJvb3QtY2EvcHViL2NhY2VydC9jYWNlcnQuY3J0MEcGCCsGAQUF
BzAChjtodHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9j
YWNlcnQvY2FjZXJ0LmNydDANBgkqhkiG9w0BAQsFAAOCAQEATwqf7vDqB6muBNS2
cGR+VxR0IGDWMvYYrX1HIIK5wvSd+/LEBPDyMsDaVadLFYh6U3K5wTbeC7d7XFpP
cIumj9Rvc2OuE5Tv03+YcsexNvPRjZ/7bVrCxQlfQMoRaKO1VOhIdeFuINfLotJI
ug1Ygo/MezS0QGeOOtXUccDtOiFj4vXUqBpScw6l4Zpwig0+Dl0YhKhov0eTceGD
FkoAS10YRRTKPn3uvJqkwdLB/5bbSV5affZFpZaf72wer1xY178OsntFm1FObJOo
g664LjBzmAJjaJtjl9hjtWMSXvtj9gfFF8NR5ZyM7vgH+8QmAu29JTcXsPWAbnBR
nl73Pw==
-----END CERTIFICATE-----
" > $HOME/.cat_installer/ca.pem
function run_python_script {
PASSWORD=$( echo "$PASSWORD" | sed "s/'/\\\'/g" )
python << EOF > /dev/null 2>&1
#-*- coding: utf-8 -*-
import dbus
import re
import sys
import uuid
import os

class EduroamNMConfigTool:

    def connect_to_NM(self):
        #connect to DBus
        try:
            self.bus = dbus.SystemBus()
        except dbus.exceptions.DBusException:
            print "Can't connect to DBus"
            sys.exit(2)
        #main service name
        self.system_service_name = "org.freedesktop.NetworkManager"
        #check NM version
        nm_version = self.check_nm_version()
        if nm_version == "0.9" or nm_version == "1.0":
            self.settings_service_name = self.system_service_name
            self.connection_interface_name = "org.freedesktop.NetworkManager.Settings.Connection"
            #settings proxy
            sysproxy = self.bus.get_object(self.settings_service_name, "/org/freedesktop/NetworkManager/Settings")
            #settings intrface
            self.settings = dbus.Interface(sysproxy, "org.freedesktop.NetworkManager.Settings")
        elif nm_version == "0.8":
            #self.settings_service_name = "org.freedesktop.NetworkManagerUserSettings"
            self.settings_service_name = "org.freedesktop.NetworkManager"
            self.connection_interface_name = "org.freedesktop.NetworkManagerSettings.Connection"
            #settings proxy
            sysproxy = self.bus.get_object(self.settings_service_name, "/org/freedesktop/NetworkManagerSettings")
            #settings intrface
            self.settings = dbus.Interface(sysproxy, "org.freedesktop.NetworkManagerSettings")
        else:
            print "This Network Manager version is not supported"
            sys.exit(2)

    def check_opts(self):
        self.cacert_file = '${HOME}/.cat_installer/ca.pem'
        self.pfx_file = '${HOME}/.cat_installer/user.p12'
        if not os.path.isfile(self.cacert_file):
            print "Certificate file not found, looks like a CAT error"
            sys.exit(2)

    def check_nm_version(self):
        try:
            proxy = self.bus.get_object(self.system_service_name, "/org/freedesktop/NetworkManager")
            props = dbus.Interface(proxy, "org.freedesktop.DBus.Properties")
            version = props.Get("org.freedesktop.NetworkManager", "Version")
        except dbus.exceptions.DBusException:
            version = "0.8"
        if re.match(r'^1\.0', version):
            return "1.0"
        if re.match(r'^0\.9', version):
            return "0.9"
        if re.match(r'^0\.8', version):
            return "0.8"
        else:
            return "Unknown version"

    def byte_to_string(self, barray):
        return "".join([chr(x) for x in barray])


    def delete_existing_connections(self, ssid):
        "checks and deletes earlier connections"
        try:
            conns = self.settings.ListConnections()
        except dbus.exceptions.DBusException:
            print "DBus connection problem, a sudo might help"
            exit(3)
        for each in conns:
            con_proxy = self.bus.get_object(self.system_service_name, each)
            connection = dbus.Interface(con_proxy, "org.freedesktop.NetworkManager.Settings.Connection")
            try:
               connection_settings = connection.GetSettings()
               if connection_settings['connection']['type'] == '802-11-wireless':
                   conn_ssid = self.byte_to_string(connection_settings['802-11-wireless']['ssid'])
                   if conn_ssid == ssid:
                       connection.Delete()
            except dbus.exceptions.DBusException:
               pass

    def add_connection(self,ssid):
        s_con = dbus.Dictionary({
            'type': '802-11-wireless',
            'uuid': str(uuid.uuid4()),
            'permissions': ['user:$USER'],
            'id': ssid 
        })
        s_wifi = dbus.Dictionary({
            'ssid': dbus.ByteArray(ssid),
            'security': '802-11-wireless-security'
        })
        s_wsec = dbus.Dictionary({
            'key-mgmt': 'wpa-eap',
            'proto': ['rsn',],
            'pairwise': ['ccmp',],
            'group': ['ccmp', 'tkip']
        })
        s_8021x = dbus.Dictionary({
            'eap': ['peap'],
            'identity': '$USER_NAME',
            'ca-cert': dbus.ByteArray("file://" + self.cacert_file + "\0"),
            'subject-match': 'tubit.tu-berlin.de',
            'password': '$PASSWORD',
            'phase2-auth': 'mschapv2',
        })
        s_ip4 = dbus.Dictionary({'method': 'auto'})
        s_ip6 = dbus.Dictionary({'method': 'auto'})
        con = dbus.Dictionary({
            'connection': s_con,
            '802-11-wireless': s_wifi,
            '802-11-wireless-security': s_wsec,
            '802-1x': s_8021x,
            'ipv4': s_ip4,
            'ipv6': s_ip6
        })
        self.settings.AddConnection(con)

    def main(self):
        self.check_opts()
        ver = self.connect_to_NM()
        self.delete_existing_connections('eduroam')
        self.add_connection('eduroam')

if __name__ == "__main__":
    ENMCT = EduroamNMConfigTool()
    ENMCT.main()
EOF
}
function create_wpa_conf {
cat << EOFW >> $HOME/.cat_installer/cat_installer.conf

network={
  ssid="eduroam"
  key_mgmt=WPA-EAP
  pairwise=CCMP
  group=CCMP TKIP
  eap=PEAP
  ca_cert="${HOME}/.cat_installer/ca.pem"
  identity="${USER_NAME}"
  subject_match="tubit.tu-berlin.de"
  phase2="auth=MSCHAPV2"
  password="${PASSWORD}"
}
EOFW
chmod 600 $HOME/.cat_installer/cat_installer.conf
}
#prompt user for credentials
  user_cred
  if run_python_script ; then
   show_info "Installation erfolgreich"
else
   show_info "Konfiguration von NetworkManager fehlgeschlagen, erzeuge nun wpa_supplicant.conf Datei"
if [ -f $HOME/.cat_installer/cat_installer.conf ] ; then
  if ! ask "Datei $HOME/.cat_installer/cat_installer.conf existiert bereits, sie wird überschrieben." "Weiter" 1 ; then confirm_exit; fi
  rm $HOME/.cat_installer/cat_installer.conf
  fi
   create_wpa_conf
   show_info "Ausgabe nach $HOME/.cat_installer/cat_installer.conf geschrieben"
fi
