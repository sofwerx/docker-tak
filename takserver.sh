#!/bin/bash
set -e

export PGHOST PGPORT PGUSER PGPASSWORD PGDATABASE

cat <<EOF > CoreConfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration xmlns="http://bbn.com/marti/xml/config"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="CoreConfig.xsd">
	<network multicastTTL="5">
		<input _name="stdtcp" protocol="tcp" port="8087"/>
		<input _name="stdudp" protocol="udp" port="8087"/>
		<input _name="streamtcp" protocol="stcp" port="8088" />
		<input _name="SAproxy" protocol="mcast" group="239.2.3.1" port="6969" proxy="true"/>
		<input _name="GeoChatproxy" protocol="mcast" group="224.10.10.1" port="17012" proxy="true"/>
<!--		<announce enable="true" uid="Marti1" group="239.2.3.1" port="6969" interval="1" ip="${ANNOUNCE_IP:-192.168.1.100}" /> -->
EOF

if [ -n "${ENABLE_TLS}" ]; then
cat <<EOF >> CoreConfig.xml
		<input _name="stdssl" protocol="tls" port="8089"/>
EOF
fi

cat <<EOF >> CoreConfig.xml
		 <!--<input _name="sslauth" protocol="tls" port="8090" auth="ldap"/> -->
		<!--<input _name="stdtcpwithgroups" protocol="tcp" port="8087">-->
			<!--<filtergroup>group one</filtergroup>-->
			<!--<filtergroup>group two</filtergroup>-->
		<!--</input>-->
	</network>
	<auth>
                <!-- Example OpenLDAP -->
		<!--
		<ldap
			url="ldap://hostname.bbn.com/"
			userstring="uid={username},ou=People,dc=XXX,dc=bbn,dc=com"
			updateinterval="60"
			style="DS"
		/>
		-->

		<!-- Example ActiveDirectory -->

		<!--NOTE!! In the example below, GroupBaseDN should be specified relative to the naming context provided in the url attribute below -->
		<!-- 
		<ldap
			url="ldap://hostname.bbn.com/dc=XXX,dc=bbn,dc=com"
			userstring="DOMAIN\{username}"
			updateinterval="60"
			groupprefix=""
			style="AD"
        	ldapSecurityType="simple" 
        	serviceAccountDN="cn=fred001,cn=Users,cn=Partition1,dc=XYZ,dc=COM" 
        	serviceAccountCredential="XXXXXX" 
        	groupObjectClass="group" 
        	groupBaseRDN="CN=Groups"/>
		/>
		
		-->
	        <!--<File location="UserAuthenticationFile.xml"/>-->
	</auth>
	<submission ignoreStaleMessages="false" validateXml="false"/>

	<subscription reloadPersistent="false">
		<static _name="MulticastProxy" protocol="udp" address="239.2.3.1" port="6969" />
		<!-- example of federated subscription; requires that the flow-tag filter be active -->
		<!-- <static _name="Marti2" protocol="stcp" address="192.168.1.4" port="8087" xpath="not(//_flow-tags_[@marti2])"/>  -->
	</subscription>

	<repository enable="false" numDbConnections="10" primaryKeyBatchSize="500" insertionBatchSize="500">
	  <connection url="jdbc:postgresql://${POSTGIS_HOST:-127.0.0.1}:${POSTGIS_PORT:-5432}/${POSTGIS_DATABASE:-cot}" username="${POSTGIS_USERNAME:-cot}" password="${POSTGIS_PASSWORD:-cot}" />
	</repository>

	<repeater enable="true" periodMillis="3000" staleDelayMillis="15000">
	    <!-- Examples -->
		<repeatableType initiate-test="/event/detail/emergency[@type='911 Alert']" cancel-test="/event/detail/emergency[@cancel='true']" _name="911"/> 
		<repeatableType initiate-test="/event/detail/emergency[@type='Ring The Bell']" cancel-test="/event/detail/emergency[@cancel='true']" _name="RingTheBell"/>
		<repeatableType initiate-test="/event/detail/emergency[@type='Geo-fence Breached']" cancel-test="/event/detail/emergency[@cancel='true']" _name="GeoFenceBreach"/>
		<repeatableType initiate-test="/event/detail/emergency[@type='Troops In Contact']" cancel-test="/event/detail/emergency[@cancel='true']" _name="TroopsInContact"/>
	</repeater>

	<dissemination smartRetry="false" />

	<filter>
		<thumbnail enable="false" pixels="100"/>
		<urladd thumburl="false" fullurl="true" overwriteurl="true" />
		<flowtag enable="false" text=""/>
		<streamingbroker enable="true"/>
		<!--
		<dropfilter>
			<typefilter type="u-d-p" />
			<typefilter type="u-d-c" />
		</dropfilter>
		-->
	</filter>

	<buffer>
		<latestSA enable="true"/>
		<queue capacity="10"/>
	</buffer>

	<security>
		<tls context="TLSv1" 
			keymanager="SunX509"
			keystore="JKS" keystoreFile="certs/TAKServer.jks" keystorePass="atakatak" 
			truststore="JKS" truststoreFile="certs/truststore.jks" truststorePass="atakatak">
		   
		 <!-- <crl _name="TAKServer CA" crlFile="certs/TAKServer-ca.crl"/>  -->
		    
		</tls>
	</security>
<!--
	<federation>
	  <federation-server port="9000">
	    <tls context="TLSv1" 
		 keymanager="SunX509"
		 keystore="JKS" keystoreFile="certs/TAKServer.jks" keystorePass="atakatak" 
		 truststore="JKS" truststoreFile="certs/fed-truststore.jks" truststorePass="atakatak"/>
	  </federation-server>
	</federation>
-->
</Configuration>
EOF

#set -x
#psql -c "CREATE ROLE ${POSTGIS_USERNAME} LOGIN PASSWORD '${POSTGIS_PASSWORD}' SUPERUSER INHERIT CREATEDB NOCREATEROLE;" || true
#
#createdb --owner=${POSTGIS_USERNAME} ${POSTGIS_DATABASE} || true
#
#java -jar /opt/tak/db-utils/SchemaManager.jar upgrade

exec ./TAKServer.sh
