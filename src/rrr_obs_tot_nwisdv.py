#!/usr/bin/python
#*******************************************************************************
#rrr_obs_tot_nwisdv.py
#*******************************************************************************

#Purpose:
#Given a point shapefile containing USGS gauges and at least two attributes (the
#USGS station code and the unique identifier of the river reach on which it is 
#located), this script produces two csv files with the following information
# - rrr_obs_csv
#   . River ID (sorted in increasing order)
# - rrr_flw_csv
#   . Flow in m3/s day 1 - River ID 1, Flow in m3/s for Day 1 - River ID 2, ...
#   . Flow in m3/s day 2 - River ID 1, Flow in m3/s for Day 2 - River ID 2, ...
#   ... 
#The structure of the XML tree for USGS NWIS DV assumed here is the following:
# - queryInfo
# - timeSeries
#   - sourceInfo
#   - variable
#   - value
#     - value 1
#     - value 2
#     - ...
#     - value n
#     - qualifier
#     - method
#Author:
#Cedric H. David, 2013-2016


#*******************************************************************************
#Import Python modules
#*******************************************************************************
import sys
import fiona
import shapely.geometry
import requests
from lxml import etree
import datetime
import csv


#*******************************************************************************
#Declaration of variables (given as command line arguments)
#*******************************************************************************
# 1 - rrr_obs_shp
# 2 - rrr_str_dat
# 3 - rrr_end_dat
# 4 - rrr_obs_csv
# 5 - rrr_flw_csv


#*******************************************************************************
#Get command line arguments
#*******************************************************************************
IS_arg=len(sys.argv)
if IS_arg != 6:
     print('ERROR - 5 and only 5 arguments can be used')
     raise SystemExit(22) 

rrr_obs_shp=sys.argv[1]
rrr_str_dat=sys.argv[2]
rrr_end_dat=sys.argv[3]
rrr_obs_csv=sys.argv[4]
rrr_flw_csv=sys.argv[5]


#*******************************************************************************
#Print input information
#*******************************************************************************
print('Command line inputs')
print('- '+rrr_obs_shp)
print('- '+rrr_str_dat)
print('- '+rrr_end_dat)
print('- '+rrr_obs_csv)
print('- '+rrr_flw_csv)


#*******************************************************************************
#Check if files exist 
#*******************************************************************************
try:
     with open(rrr_obs_shp) as file:
          pass
except IOError as e:
     print('ERROR - Unable to open '+rrr_obs_shp)
     raise SystemExit(22) 


#*******************************************************************************
#Open rrr_obs_shp
#*******************************************************************************
print('Open rrr_obs_shp')

rrr_obs_lay=fiona.open(rrr_obs_shp, 'r')
IS_obs_all=len(rrr_obs_lay)
print('- The number of gauges is: '+str(IS_obs_all))

if 'COMID_1' in rrr_obs_lay[0]['properties']:
     YV_obs_id='COMID_1'
elif 'FLComID' in rrr_obs_lay[0]['properties']:
     YV_obs_id='FLComID'
else:
     print('ERROR - Neither COMID_1 nor COMID exist in '+rrr_obs_shp)
     raise SystemExit(22) 

IV_obs_all_id=[]
IV_obs_all_code=[]
for JS_obs_all in range(IS_obs_all):
     IV_obs_all_id.append(int(rrr_obs_lay[JS_obs_all]['properties'][YV_obs_id]))
     IV_obs_all_code.append(                                                   \
                       str(rrr_obs_lay[JS_obs_all]['properties']['SOURCE_FEA']))


#*******************************************************************************
#Check that service works for one known value
#*******************************************************************************
print('Check that service works for one known value')

url='http://waterservices.usgs.gov/nwis/dv/'

payload={}
payload['format']='waterml'
payload['sites']='08176500'
payload['parameterCd']='00060'
payload['startDT']='2004-01-01'
payload['endDT']='2004-01-01'
payload['statCd']='00003'
#payload = {'key1': 'value1', 'key2': 'value2'}

data=requests.get(url,payload)
tree = etree.fromstring(data.content)

if tree[1][2][0].text=='1060':
     print('- Successfully checked value for Guadalupe River at Victoria, TX,'+\
          ' for 2004-01-01')
else:
     print('ERROR - Unable to check known value')
     raise SystemExit(22) 
#Guadalupe River at Victoria, the value on 2004-01-01 should be 1060 cfs


#*******************************************************************************
#Check which stations have full data and store these
#*******************************************************************************
print('Check which stations have full data and store these')

payload['startDT']=rrr_str_dat
payload['endDT']=rrr_end_dat
IS_time=( datetime.datetime.strptime(rrr_end_dat,'%Y-%m-%d')                   \
         -datetime.datetime.strptime(rrr_str_dat,'%Y-%m-%d')).days+1
print('- A full data record would have '+str(IS_time)+' daily data points')

print('- Downloading data for the requested interval')
IV_obs_ful_id=[]
IV_obs_ful_code=[]
ZM_obs_ful_data={}
for JS_obs_all in range(IS_obs_all):
     #--------------------------------------------------------------------------
     #Obtain XML data from webservice
     #--------------------------------------------------------------------------
     payload['sites']=IV_obs_all_code[JS_obs_all]
     #Update station code 
     data=requests.get(url,payload)
     #Request data
     if data.status_code!=200:
          print('ERROR - Status code '+str(data.status_code)+' raised for '+   \
                str(payload['sites']))
          raise SystemExit(22) 
     #Make sure request did not fail

     #--------------------------------------------------------------------------
     #Process XML data
     #--------------------------------------------------------------------------
     tree = etree.fromstring(data.content)
     if len(tree) < 2:
          print('   . '+str(JS_obs_all)+'/'+str(IS_obs_all)+' '                \
                       +str(IV_obs_all_code[JS_obs_all])+' has no data')
     else: 
          #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          #Check that XML structure is as expected
          #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          if tree[1].tag[-10:]!='timeSeries' or tree[1][2].tag[-6:]!='values':
               print('ERROR - Unexpected XML structure for '+                  \
                      str(payload['sites']))
               raise SystemExit(22) 

          #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          #Count the number of data points 
          #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          IS_data=0
          for JS_values in range(len(tree[1][2])):
               if tree[1][2][JS_values].tag[-5:]=='value':
                    IS_data=IS_data+1

          #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          #Store information for full sites only
          #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          if IS_data!=IS_time:
               print('   . '+str(JS_obs_all)+'/'+str(IS_obs_all)+' '           \
                            +str(IV_obs_all_code[JS_obs_all])+' has some data')
          else:
               print('   . '+str(JS_obs_all)+'/'+str(IS_obs_all)+' '           \
                            +str(IV_obs_all_code[JS_obs_all])+' has full data')
               IV_obs_ful_id.append(IV_obs_all_id[JS_obs_all])
               IV_obs_ful_code.append(IV_obs_all_code[JS_obs_all])
               ZM_obs_ful_data[IV_obs_all_code[JS_obs_all]]=[]
               for JS_time in range(IS_time):
                    ZM_obs_ful_data[IV_obs_all_code[JS_obs_all]].append(       \
                                                float(tree[1][2][JS_time].text))

IS_obs_ful=len(IV_obs_ful_id)
print('- The number of gauges with full data record is: '+str(IS_obs_ful))


#*******************************************************************************
#Selecting the gauges with full data located on unique reaches
#*******************************************************************************
print('Selecting the gauges with full data located on unique reaches')

IV_obs_tot_id=list(set(IV_obs_ful_id))
#Select only the unique river IDs
IV_obs_tot_id.sort()
#Sort the IDs
IS_obs_tot=len(IV_obs_tot_id)
print('- The number of gauges with full data record and on unique reaches is: '\
      +str(IS_obs_tot))

IV_obs_tot_code=['99999999']*IS_obs_tot
for JS_obs_tot in range(IS_obs_tot):
     for JS_obs_ful in range(IS_obs_ful):
          if IV_obs_tot_id[JS_obs_tot]==IV_obs_ful_id[JS_obs_ful]:
               if IV_obs_tot_code[JS_obs_tot]>IV_obs_ful_code[JS_obs_ful]:
                    IV_obs_tot_code[JS_obs_tot]=IV_obs_ful_code[JS_obs_ful]

print('- The smallest USGS code was selected if multiple gauges on single reach')


#*******************************************************************************
#Building a table with all full data
#*******************************************************************************
print('Building a table with all full data')

ZM_obs_tot_data=[]
for JS_time in range(IS_time):
     ZM_obs_tot_data.append([])
     for JS_obs_tot in range(IS_obs_tot):
          ZS_val=ZM_obs_ful_data[IV_obs_tot_code[JS_obs_tot]][JS_time]
          ZS_val=ZS_val*(0.3048**3)
          #convert from cfs to m3/s
          ZM_obs_tot_data[JS_time].append(ZS_val)

print('- Data was also converted from cfs to m3/s')


#*******************************************************************************
#Write outputs
#*******************************************************************************
print('Writing files')

print(' - rrr_obs_csv')
with open(rrr_obs_csv, 'wb') as csvfile:
     csvwriter = csv.writer(csvfile, dialect='excel')
     for JS_obs_tot in range(IS_obs_tot):
          csvwriter.writerow([IV_obs_tot_id[JS_obs_tot]]) 

print(' - rrr_flw_csv')
with open(rrr_flw_csv, 'wb') as csvfile:
     csvwriter = csv.writer(csvfile, dialect='excel')
     for JS_time in range(IS_time):
          csvwriter.writerow(ZM_obs_tot_data[JS_time]) 


#*******************************************************************************
#End
#*******************************************************************************
