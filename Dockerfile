ARG IMAGE=intersystemsdc/iris-community:latest
#ARG IMAGE=iris2021:2
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
COPY csp csp
RUN mkdir /ghostdb/ && mkdir /voldata/ && mkdir /voldata/irisdb
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp /opt/irisapp/csp /opt/irisapp/csp/* /ghostdb/ /voldata/ /voldata/irisdb/
RUN chmod 775 /opt/irisapp/csp /opt/irisapp/csp/*

USER irisowner

COPY  Installer.cls .
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} src src
COPY data data
COPY irissession.sh /
SHELL ["/irissession.sh"]

RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  zn "%SYS" \
  write "Create web application ..." \
  set webName = "/crud" \
  set webProperties("DispatchClass") = "Sample.PersonREST" \
  set webProperties("NameSpace") = "IRISAPP" \
  set webProperties("Enabled") = 1 \
  set webProperties("AutheEnabled") = 32 \
  set sc = ##class(Security.Applications).Create(webName, .webProperties) \
  write sc \
  write "Web application "_webName_" has been created!" 
  #zn "IRISAPP" \
  #zpm "install swagger-ui" \
  #zpm "install webterminal"

# bringing the standard shell back
SHELL ["/bin/bash", "-c"]

HEALTHCHECK --interval=10s --timeout=3s --retries=2 CMD wget --timeout 1 --quiet http://localhost:52773/csp/user/cache_status.cxw -O - || exit 1

USER root
#COPY vcopy.sh vcopy.sh
#RUN rm -f $ISC_PACKAGE_INSTALLDIR/mgr/alerts.log $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ $ISC_PACKAGE_INSTALLDIR/mgr/journal/* && cp -Rpf /voldata/* /ghostdb/ && rm -fr /voldata/* \
#  && chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp/vcopy.sh && chmod +x /opt/irisapp/vcopy.sh

# we need Write privilege for UnitTest
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp/src/UnitTest/* && chmod +w /opt/irisapp/src/UnitTest/*

# [INFO] Starting InterSystems IRIS instance IRIS...
# [INFO] Invalid registry ownership
# [ERROR] Command "iris start IRIS quietly" exited with status 256
##RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/etc/irissys/iris.reg

USER ${ISC_PACKAGE_MGRUSER}
