
import requests
import json
# from requests_toolbelt.multipart import encoder
from requests_toolbelt import MultipartEncoder, MultipartEncoderMonitor


token_string = 'F-2LvppZzzHvbsNHx6CfhCwhcTfQSpexHmem7dTMwoQ1'

projectId = 'YBUHozJ_CE61sqbmzeBi-g'
appId = 'tNTQ-b6pPEWwgp_-cjcmdg'

appId_dev_Android = 'pN_i_FqWS0qG0FZ5cft76Q'
appId_dev_iOS = 'isvOaZVfYEOnDxdxNen8FQ'
appId_product_Android = 'YICJNVLdw06T-HZPIRKb4w'
appId_product_iOS = 'tNTQ-b6pPEWwgp_-cjcmdg'
appId_test_Android = 'IE4EQbuLqU-2UHknI-bXeg'
appId_test_iOS = '8nXjTpPyiUudldbkDJaSHA'

def upload(env, os, package_path, version):
    if os == 'iOS':
        if env == 'development':
            appId = appId_dev_iOS
        elif env == 'test':
            appId = appId_test_iOS
        elif env == 'production':
            appId = appId_product_iOS
        else:
            appId = appId_dev_iOS
        
        file_name = os + version + '.ipa'
    elif os == 'Android':
        if env == 'development':
            appId = appId_dev_Android
        elif env == 'test':
            appId = appId_test_Android
        elif env == 'production':
            appId = appId_product_Android
        else:
            appId = appId_dev_iOS
        
        file_name = os + version + '.apk'
    else:
        appId = ''

    uploadApplication(appId, env, os, package_path, file_name)
        
    
    

def uploadApplication(theId, env, os, package_path, file_name):
    appId = theId
    host = 'https://api.testproject.io/v2/projects/'
    url_prefix = host + projectId + '/applications/' + appId
    headers = {'content-type': 'application/json', "Authorization": "{}".format(token_string)}

    print('appid: ' + theId + ", get upload-link for " + env + " " + os)
    response_uploadurl = requests.get(url_prefix + '/file/upload-link', headers=headers)
    data = json.loads(response_uploadurl.text)

    # with open("/Users/sagegu/Downloads/bb.ipa", "rb") as a_file:
    #     file_dict = {"abc.ipa": a_file}
    #     response = requests.put(data['url'], files=file_dict)
    
    #     print(response)
    #     print(response.text)
    #     print(response.status_code)

    # upload and show progress
    def my_callback(monitor):
        # Your callback function
        print (monitor.bytes_read)

    e = MultipartEncoder(
        { file_name: open(package_path, 'rb') }
        )
    m = MultipartEncoderMonitor(e, my_callback)
    r = requests.put(data['url'], data=m )


    # ---------------------
    # Confirm file uploaded
    print("Confirm upload")
    confirm_file = host + projectId + '/applications/' + appId + '/file'
    payload = {'fileName': file_name}
    confirm_file_response = requests.post(confirm_file, data=json.dumps(payload), headers=headers)
    print(confirm_file_response.status_code)                  

# uploadApplication(appId_product_iOS, 'product ios', '/Users/sagegu/Desktop/1/personalAppRN.ipa', 'prod_ios.ipa')

# package_path = '/Users/sagegu/Desktop/1/per.ipa'
# version = '1.8.28.1'
# # upload("development", "iOS", package_path, version)
# upload("production", "iOS", package_path, version)


print("Hello iHealth!") 
 