# robot_SoapLibrary
PyPi downloads Total downloads Latest Version Tests

Robot-Framework-SOAP-Library
SOAP Library for Robot Framework

Compatibility
Python 3.7 +
Zeep 3.1.0 +
Introduction
The SoapLibrary was created for those who want to use the Robot Framework as if they were using SoapUI, just send the request XML and get the response XML.

![image](https://github.com/carloseduardo1984/robot_SoapLibrary/assets/33332202/ec2e411e-41f9-40dd-a6b3-5ba6bfe69a91)


Instalation
For the first time install:

pip install robotframework-soaplibrary
Or you can upgrade with:

pip install --upgrade robotframework-soaplibrary
Example
    *** Settings ***
    Library           SoapLibrary
    Library           OperatingSystem

    *** Test Cases ***
    Example
        Create Soap Client    http://endpoint.com/example.asmx?wsdl
        ${response}    Call SOAP Method With XML    ${CURDIR}/request.xml
        ${text}    Get Data From XML By Tag    ${response}    tag_name
        Log    ${text}
        Save XML To File    ${response}    ${CURDIR}    response_test
Example with certificate
You can see here an example of how to use OPENSSL to access a webservice with TLS certificate. (Thanks Michael Hallik)

Keyword Documentation
You can find the keywords documentation here > https://raw.githack.com/Altran-PT-GDC/Robot-Framework-SOAP-Library/master/Doc/SoapLibrary.html
