FROM ubuntu:latest

WORKDIR /app

COPY ./stm32cubeprg-lin-v2-21-0.zip stm32.zip

RUN apt-get update && apt install -y unzip && rm -rf /var/lib/apt/lists/* && \
    unzip stm32.zip && \
    echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' > auto-install.xml && \
    echo '<AutomatedInstallation langpack="eng">' >> auto-install.xml && \
    echo ' <com.st.CustomPanels.CheckedHelloPorgrammerPanel id="Hello.panel"/>' >> auto-install.xml && \
    echo ' <com.izforge.izpack.panels.info.InfoPanel id="Info.panel"/>' >> auto-install.xml && \
    echo ' <com.izforge.izpack.panels.licence.LicencePanel id="Licence.panel"/>' >> auto-install.xml && \
    echo ' <com.st.CustomPanels.TargetProgrammerPanel id="target.panel">' >> auto-install.xml && \
    echo ' <installpath>/app/stm32cube</installpath>' >> auto-install.xml && \
    echo ' </com.st.CustomPanels.TargetProgrammerPanel>' >> auto-install.xml && \
    echo ' <com.izforge.izpack.panels.install.InstallPanel id="Install.panel"/>' >> auto-install.xml && \
    echo ' <com.izforge.izpack.panels.finish.FinishPanel id="Finish.panel"/>' >> auto-install.xml && \
    echo '</AutomatedInstallation>' >> auto-install.xml && \
    ./SetupSTM32CubeProgrammer-2.21.0.linux auto-install.xml && \
    rm stm32.zip
