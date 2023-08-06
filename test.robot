*** Settings ***
Library           SoapLibrary
Library           Collections
Library           OperatingSystem
Library           XML    use_lxml=True
Library           Process

*** Variables ***
${requests_dir}                      ${CURDIR}${/}Requests
${wsdl_correios_price_calculator}    http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx?wsdl
${wsdl_country_info}                 http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso?wsdl
${wsdl_calculator}                   https://ecs.syr.edu/faculty/fawcett/Handouts/cse775/code/calcWebService/Calc.asmx?wsdl
${request_string}                    <Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><Add xmlns="http://tempuri.org/"><a>5</a><b>3</b></Add></Body></Envelope>
${request_string_500}                <Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><Add xmlns="http://tempuri.org/"><a>a</a><b>3</b></Add></Body></Envelope>

*** Test Cases ***
Test Call Soap Method
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${response}    Call SOAP Method    Add    2    1
    should be equal as integers    3    ${response}

Test Call Soap Method Error
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${response}    Call SOAP Method    Add    2    X    status=anything
    Should Contain    ${response}    Input string was not in a correct format.

Test read
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${response}    Call SOAP Method With XML    ${requests_dir}${/}Request_Calculator.xml
    ${result}    Get Data From XML By Tag    ${response}    AddResult
    should be equal    8    ${result}

Test read With Binding Address
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False    use_binding_address=True
    ${response}    Call SOAP Method With XML    ${requests_dir}${/}Request_Calculator.xml
    ${result}    Get Data From XML By Tag    ${response}    AddResult
    should be equal    8    ${result}

Test read string xml
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${response}    Call SOAP Method With String XML  ${request_string}
    ${result}    Get Data From XML By Tag    ${response}    AddResult
    should be equal    8    ${result}

Test Edit and Read
    [Tags]    calculator
    Remove File    ${requests_dir}${/}New_Request_Calculator.xml
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${dict}    Create Dictionary    a=9    b=5
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}Request_Calculator.xml    ${dict}    New_Request_Calculator
    ${response}    Call SOAP Method With XML    ${xml_edited}
    ${result}    Get Data From XML By Tag    ${response}    AddResult
    should be equal    14    ${result}
    Should Exist    ${requests_dir}${/}New_Request_Calculator.xml

Test Call SOAP Method with XML Anything
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${response}    Call SOAP Method With XML  ${requests_dir}${/}Request_Calculator_500.xml    status=anything
    ${result}    Get Data From XML By Tag    ${response}    faultstring
    log    ${result}
    Should Contain    ${result}    Server was unable to read request.

Test Call SOAP Method with String XML Anything
    [Tags]    calculator
    Create Soap Client    ${wsdl_calculator}    ssl_verify=False
    ${response}    Call SOAP Method With String XML  ${request_string_500}    status=anything
    ${result}    Get Data From XML By Tag    ${response}    faultstring
    log    ${result}
    Should Contain    ${result}    Server was unable to read request.

Test read utf8
    [Tags]    country_info
    #todo find an API with response in utf8
    Create Soap Client    ${wsdl_country_info}
    ${response}    Call SOAP Method With XML    ${requests_dir}${/}request_capital.xml
    ${City}    Get Data From XML By Tag    ${response}    m:CapitalCityResult
    should be equal as strings    ${City}    Lisbon

Test Get Last Response Object
    [Tags]    country_info
    Create Soap Client    ${wsdl_country_info}
    Call SOAP Method With XML    ${requests_dir}${/}request_capital.xml
    ${response_object}    Get Last Response Object
    Should Be Equal As Integers    ${response_object.status_code}    200
    Should Contain    ${response_object.text}    Lisbon
    Dictionary Should Contain Key    ${response_object.headers}    Content-Type

Test Save File Response
    [Tags]    country_info
    Remove File    ${CURDIR}${/}response_test.xml
    Create Soap Client    ${wsdl_country_info}
    ${response}    Call SOAP Method With XML    ${requests_dir}${/}request_capital.xml
    ${file}    Save XML To File    ${response}    ${CURDIR}    response_test
    Should Exist    ${CURDIR}${/}response_test.xml

Test Read tags with index
    [Tags]    correios
    Create Soap Client    ${wsdl_correios_price_calculator}
    ${response}    Call SOAP Method With XML    ${requests_dir}${/}Request_ListaServicos.xml
    ${codigo}    Get Data From XML By Tag    ${response}    codigo    index=99
    should be equal as integers    11835    ${codigo}

Test Response to Dict
    [Tags]    correios
    Create Soap Client    ${wsdl_correios_price_calculator}
    ${response}    Call SOAP Method With XML    ${requests_dir}${/}Request_CalcPrecoPrazo.xml
    ${dict_response}    Convert XML Response to Dictionary    ${response}
    ${type}    evaluate    str(type(${dict_response}))
    Should Contain    ${type}    'dict'
    ${body}    Get From Dictionary    ${dict_response}    Body
    ${calcprecoprazoresponse}    Get From Dictionary    ${body}    CalcPrecoPrazoResponse
    ${calcprecoprazoresult}    Get From Dictionary    ${calcprecoprazoresponse}    CalcPrecoPrazoResult
    ${servicos}    Get From Dictionary    ${calcprecoprazoresult}    Servicos
    ${cservico}    Get From Dictionary    ${servicos}    cServico
    ${valorsemadicionais}    Get From Dictionary    ${cservico}    ValorSemAdicionais
    should be equal    24,90    ${valorsemadicionais}

Test Edit XML Request 1
    [Tags]    edit_xml
    [Documentation]    Change all names, dates and reasons tags
    ${new_value_dict}    Create Dictionary    startDate=15-01-2020    name=Joaquim    Reason=1515
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request    repeated_tags=0
    ${new_value_dict}    Create Dictionary    startDate=16-01-2020    name2=Joao    Reason=1616
    ${xml_edited}    Edit XML Request    ${xml_edited}    ${new_value_dict}    New_Request    repeated_tags=1
    ${new_value_dict}    Create Dictionary    startDate=17-01-2020    Reason=1717
    ${xml_edited}    Edit XML Request    ${xml_edited}    ${new_value_dict}    New_Request    repeated_tags=2
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    Joaquim
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    Joao
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    15-01-2020
    Should be equal    ${text_date[1].text}    16-01-2020
    Should be equal    ${text_date[2].text}    17-01-2020
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    1515
    Should be equal    ${text_reason[1].text}    1616
    Should be equal    ${text_reason[2].text}    1717

Test Edit XML Request 2
    [Tags]    edit_xml
    [Documentation]    Change name, date and reason on tag 0
    ${new_value_dict}    Create Dictionary    startDate=20-01-2020    name=Maria    Reason=2020
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request    repeated_tags=0
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    Maria
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    BBBB
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    20-01-2020
    Should be equal    ${text_date[1].text}    2019-06-03
    Should be equal    ${text_date[2].text}    2019-06-03
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    2020
    Should be equal    ${text_reason[1].text}    0000
    Should be equal    ${text_reason[2].text}    0000

Test Edit XML Request 3
    [Tags]    edit_xml
    [Documentation]    Change name2, date and reason on tag 1
    ${new_value_dict}    Create Dictionary    startDate=22-01-2020    name2=Joana    Reason=2222
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request    repeated_tags=1
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    AAAAA
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    Joana
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    2019-06-03
    Should be equal    ${text_date[1].text}    22-01-2020
    Should be equal    ${text_date[2].text}    2019-06-03
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    0000
    Should be equal    ${text_reason[1].text}    2222
    Should be equal    ${text_reason[2].text}    0000

Test Edit XML Request 4
    [Tags]    edit_xml
    [Documentation]    Change date and Reason on tag 2
    ${new_value_dict}    Create Dictionary    startDate=25-01-2020    Reason=2525
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request    repeated_tags=2
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    AAAAA
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    BBBB
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    2019-06-03
    Should be equal    ${text_date[1].text}    2019-06-03
    Should be equal    ${text_date[2].text}    25-01-2020
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    0000
    Should be equal    ${text_reason[1].text}    0000
    Should be equal    ${text_reason[2].text}    2525

Test Edit XML Request 5
    [Tags]    edit_xml
    [Documentation]    Change name, date and reason in Tags 0 and 1
    ${new_value_dict}    Create Dictionary    startDate=15-01-2020    name=Joaquim    Reason=1515
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request    repeated_tags=0
    ${new_value_dict}    Create Dictionary    startDate=16-01-2020    name2=Joao    Reason=1616
    ${xml_edited}    Edit XML Request    ${xml_edited}    ${new_value_dict}    New_Request    repeated_tags=1
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    Joaquim
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    Joao
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    15-01-2020
    Should be equal    ${text_date[1].text}    16-01-2020
    Should be equal    ${text_date[2].text}    2019-06-03
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    1515
    Should be equal    ${text_reason[1].text}    1616
    Should be equal    ${text_reason[2].text}    0000

Test Edit XML Request 6
    [Tags]    edit_xml
    [Documentation]    Change name, date and reason in Tags 1 and 2
    ${new_value_dict}    Create Dictionary    startDate=15-01-2020    name2=Joaquim    Reason=1515
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request    repeated_tags=1
    ${new_value_dict}    Create Dictionary    startDate=16-01-2020    Reason=1616
    ${xml_edited}    Edit XML Request    ${xml_edited}    ${new_value_dict}    New_Request    repeated_tags=2
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    AAAAA
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    Joaquim
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    2019-06-03
    Should be equal    ${text_date[1].text}    15-01-2020
    Should be equal    ${text_date[2].text}    16-01-2020
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    0000
    Should be equal    ${text_reason[1].text}    1515
    Should be equal    ${text_reason[2].text}    1616

Test Edit XML Request 7
    [Tags]    edit_xml
    [Documentation]    Change only the name tag
    ${new_value_dict}    Create Dictionary    name=Carlota
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    Carlota
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    BBBB
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    2019-06-03
    Should be equal    ${text_date[1].text}    2019-06-03
    Should be equal    ${text_date[2].text}    2019-06-03
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    0000
    Should be equal    ${text_reason[1].text}    0000
    Should be equal    ${text_reason[2].text}    0000

Test Edit XML Request 8
    [Tags]    edit_xml
    [Documentation]    Change all dates tags
    ${new_value_dict}    Create Dictionary    startDate=07-06-2020
    ${xml_edited}    Edit XML Request    ${requests_dir}${/}request.xml    ${new_value_dict}    New_Request
    ${data}    Parse XML    ${requests_dir}${/}New_Request.xml    keep_clark_notation=True
    ${text_name}    Evaluate Xpath    ${data}    //name
    Should be equal    ${text_name[0].text}    AAAAA
    ${text_name2}    Evaluate Xpath    ${data}    //name2
    Should be equal    ${text_name2[0].text}    BBBB
    ${text_date}    Evaluate Xpath    ${data}    //startDate
    Should be equal    ${text_date[0].text}    07-06-2020
    Should be equal    ${text_date[1].text}    07-06-2020
    Should be equal    ${text_date[2].text}    07-06-2020
    ${text_reason}    Evaluate Xpath    ${data}    //Reason
    Should be equal    ${text_reason[0].text}    0000
    Should be equal    ${text_reason[1].text}    0000
    Should be equal    ${text_reason[2].text}    0000