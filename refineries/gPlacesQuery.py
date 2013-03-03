import urllib as url
import json, sys, time
sys.path.append('../ahb_python')
import db


#targetTable='g_mill_query'
targetTable=sys.argv[1]
#srid=97260
srid=sys.argv[2]

placesApiKey='AIzaSyAvfYLzTvK9xfIzwRMkWifY_WZqQpFQsVw'
baseUrl="https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s"
insertQuery="insert into %s (name,keyw,search_str,jsn, fmt_addr, geom) values ($$%s$$,'%s','%s',$$%s$$,$$%s$$,%s)"
transPt="st_transform(st_setsrid(st_makepoint(%s,%s),4326),%s)"

#get county and state names. State names retruns too many results and only the first 20(resut pages) x 60(results per page) are added.
states=[i[0] for i in db.query("select distinct name||'+'||state from county, afri_pbound  where st_intersects(boundary,geom);", search_path='public, national_atlas, afri')]

#allowTypes=['establishment']

gKeywords={'wood mill':['biomass','sawmill','lumber mill','pulp mill'],'name_exclude':['Store','National Park','Campground','Fishing', 'Foundation','Books','Saws','Chamber of Commerce','Business','Fermentation','Nursery','Culture','Tree Service','Consulting','Snow Removal','Apartments','Market','Motel','Hotel','Liquor','Real Estate','Cafe','Building','Integrative','Medicine','Museum','Fireplace','McDonald\'s','Appraisal', 'Design Lab','Furnishings','Building Council','Stadium','Machine Shop','Hauling','REALTOR','Ranger Station','Universal Free Spirit','PUD','Repair','Restauraunt','Air Monitoring','Grill','Packaging','Mobotec','Dental','Inn','Association','Library'], 'type_exclude':['furniture_store','electrician','local_government_office','bus_station', 'park','rv_park','university','campground','food','transit_station','library','lodging','restauraunt','food','electronics_store','route','doctor','car_repair']}


def queryUrlString(pagetoken='', pt=False):
    """reformats query string to use next page token url if there are multiple pages (60 results max per API query)"""
    if pt==True:
        queryUrlString="sensor=false&pagetoken="+pagetoken+"&key=%s"
    else:
        queryUrlString="%s+in+%s&sensor=false&key=%s"
    return queryUrlString


def checkRecord(kwDict, result, table=targetTable):
    """check to see if keywords are in the address. Allows us to limit keyword searching to everythong BUT address"""
    isExcluded=False
    
    #check for keywords in address. removes things like Sawmill Road
    for k in kwDict['wood mill']:
        if k in result['formatted_address']:
            print 'found keyword (%s) in address:\n\t%s\n....this record will be excluded form the database\n'%(k,result['formatted_address'])
            isExcluded=True
        if k.capitalize() in result['formatted_address']:
            print 'found keyword (%s) in address:\n\t%s\n....this record will be excluded form the database\n'%(k.capitalize(),result['formatted_address'])
            isExcluded=True

    #remove random results/
    for ex in kwDict['name_exclude']:
        if ex in result['name']:
            print 'found a random result (%s) in name:\n\t%s\n...this record will be excluded from the database\n'%(ex, result['name'])
            isExcluded=True

    #remove odd types like 'bus_station'
    for t in kwDict['type_exclude']:
        try:
            result['types']
        except:
            print 'no types in this record'
            break
        if t in result['types']:
            print 'found an odd type (%s) in types::\n\t%s\n...this record will be excluded from the database\n'%(t, result['types'])
            isExcluded=True
            
    #check to see if the record already exists in the database
    if db.query("select count(*) from %s where name = $$%s$$"%(table, result['name']), search_path='refineries')[0][0]>0:
        isExcluded=True
        print 'record already exists'
        
    return isExcluded

def queryToDB(st,kw,js):
    """run checks on the json and drop it to the DB if checks succeed"""
    for r in js['results']:
        lat=r['geometry']['location']['lat']
        lng=r['geometry']['location']['lng']
        try:
            ar="{\" \"}".replace(" ","\",\"".join([i for i in r['types']]))
        except:
            ar="{\"unknown\"}"
        if checkRecord(gKeywords,r)==True:
            break
        else:
            db.queryCommit(insertQuery%(targetTable,r['name'],ar,k,r,r['formatted_address'],transPt%(lng,lat,srid)),search_path='refineries, public')
            print 'name:\t%s\naddress:\t%s\n\n'%(r['name'],r['formatted_address'])



for st in states:
    for k in gKeywords['wood mill']:
        queryString=queryUrlString(pt=False)%(k, st,placesApiKey)
        print baseUrl%queryString
        js=json.loads(url.urlopen(baseUrl%queryString).read())
        queryToDB(st,k,js)
        if js.keys()[1]=='next_page_token':
            token=js['next_page_token']
            for resPage in range(1,21):
                try:    
                    nextPage=baseUrl%queryUrlString(pagetoken=token,pt=True)%placesApiKey
                    jsNxt=json.loads(url.urlopen(nextPage).read())
                    queryToDB(st,k,jsNxt)
                    
                except:
                    print 'failed to conform json to table'
                    break
                time.sleep(0.5)
                
#    print baseUrl%queryString
    
                                
# types={'accounting':False ,
#         'airport':False ,
#         'amusement_park':False ,
#         'aquarium':False ,
#         'art_gallery':False ,
#         'atm':False ,
#         'bakery':False ,
#         'bank':False ,
#         'bar':False ,
# 	'beauty_salon':False ,
# 	'bicycle_store':False ,
# 	'book_store':False ,
# 	'bowling_alley':False ,
# 	'bus_station':False ,
# 	'cafe':False ,
# 	'campground':False ,
# 	'car_dealer':False ,
# 	'car_rental':False ,
# 	'car_repair':False ,
# 	'car_wash':False ,
# 	'casino':False ,
# 	'cemetery':False ,
# 	'church':False ,
# 	'city_hall':False ,
# 	'clothing_store':False ,
# 	'convenience_store':False ,
# 	'courthouse':False ,
# 	'dentist':False ,
# 	'department_store':False ,
# 	'doctor':False ,
# 	'electrician':False ,
# 	'electronics_store':False ,
# 	'embassy':False ,
# 	'establishment':False ,
# 	'finance':False ,
# 	'fire_station':False ,
# 	'florist':False ,
# 	'food':False ,
# 	'funeral_home':False ,
# 	'furniture_store':False ,
# 	'gas_station':False ,
# 	'general_contractor':False ,
# 	'grocery_or_supermarket':False ,
# 	'gym':False ,
# 	'hair_care':False ,
# 	'hardware_store':False ,
# 	'health':False ,
# 	'hindu_temple':False ,
# 	'home_goods_store':False ,
# 	'hospital':False ,
# 	'insurance_agency':False ,
# 	'jewelry_store':False ,
# 	'laundry':False ,
# 	'lawyer':False ,
# 	'library':False ,
# 	'liquor_store':False ,
# 	'local_government_office':False ,
# 	'locksmith':False ,
# 	'lodging':False ,
# 	'meal_delivery':False ,
# 	'meal_takeaway':False ,
# 	'mosque':False ,
# 	'movie_rental':False ,
# 	'movie_theater':False ,
# 	'moving_company':False ,
# 	'museum':False ,
# 	'night_club':False ,
# 	'painter':False ,
# 	'park':False ,
# 	'parking':False ,
# 	'pet_store':False ,
# 	'pharmacy':False ,
# 	'physiotherapist':False ,
# 	'place_of_worship':False ,
# 	'plumber':False ,
# 	'police':False ,
# 	'post_office':False ,
# 	'real_estate_agency':False ,
# 	'restaurant':False ,
# 	'roofing_contractor':False ,
# 	'rv_park':False ,
# 	'school':False ,
# 	'shoe_store':False ,
# 	'shopping_mall':False ,
# 	'spa':False ,
# 	'stadium':False ,
# 	'storage':False ,
# 	'store':False ,
# 	'subway_station':False ,
# 	'synagogue':False ,
# 	'taxi_stand':False ,
# 	'train_station':False ,
# 	'travel_agency':False ,
# 	'university':False ,
# 	'veterinary_care':False ,
# 	'zoo':False ,
# 	'administrative_area_level_1':False ,
# 	'administrative_area_level_2':False ,
# 	'administrative_area_level_3':False ,
# 	'colloquial_area':False ,
# 	'country':False ,
# 	'floor':False ,
# 	'geocode':False ,
# 	'intersection':False ,
# 	'locality':False ,
# 	'natural_feature':False ,
# 	'neighborhood':False ,
# 	'political':False ,
# 	'point_of_interest':False ,
# 	'post_box':False ,
# 	'postal_code':False ,
# 	'postal_code_prefix':False ,
# 	'postal_town':False ,
# 	'premise':False ,
# 	'room':False ,
# 	'route':False ,
# 	'street_address':False ,
# 	'street_number':False ,
# 	'sublocality':False ,
# 	'sublocality_level_4':False ,
# 	'sublocality_level_5':False ,
# 	'sublocality_level_3':False ,
# 	'sublocality_level_2':False ,
# 	'sublocality_level_1':False ,
# 	'subpremise':False ,
# 	'transit_station':False}
