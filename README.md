# Ding Dong and its amazing scraping app

Ahoï fellow scraper, if you're looking at this README, it is probably because you're wondering what the heck is going out with all this ScraperFramework Thingy. 

No worries, here at Ding Dong ™, we like to document every step we take every once in a while (basically when things get out of hands with tons of methods, like right now basically).

This documentation will explain how we can make a beautiful scraper with the methods we developped. It's not rocket science, don't worry.

# DB Schema - Property

When we scrap a website, we insert in our db a property, composed with those columns : 

```ruby
price:integer
title:string (deprecated)
description:text
link:string
rooms_number:integer
bedrooms_number:integer
surface:integer
flat_type:string, default: "N/C"
agency_name:string, default: "N/C"
contact_number:string, default: "N/C"
source:string
floor:integer
has_elevator:boolean
images:text, default: [], array=true
area_id:integer 
```

Rules about rooms_number, bedrooms_number, floor, has_elevator, price and surface, if we don't have the information, we pass a value of null. 


There's others column but we will delete it, because they are deprecated

# Logic for Property Insertion

When we scrap a website, we first go to a main page to see a list composed with the latests properties uploaded by agencies, that displays for their users many cards with, generally the price, the surface, the area and a link.

With those 4 informations, or sometimes only 3 informations, we want to determine if we already scraped the property or not. 

We only do this for performance reasons, we don't want to go on a webpage if we already have scrapped this property. And we don't want to slow down our scrapers.


## go_to_prop?(prop, time)
Return true or false

This method is the first checker to determine if we have a property in our data base.

The "prop" parameters is a hash composed with 3 or 4 keys :
``` surface``` ``` price``` ``` area``` ``` link```

The ```time```parameters is an integer that determines a time frame in days. (ex: ```time = 1``` is a one day time frame)

### is_prop_fake? First Step

If we have the value of price and surface (it isn't ```nil``` or equal to ```0```) we check if the square meter price is under 5000€ in Paris, or 1000€ in other zones, then we determined that this isn't a property we want to insert. 

If we don't have those values (price and surface), we decide to keep up a further inspection because maybe we can get those values in the show of the property, so it's not discrimated.



### is_link_in_db? Second Step
We check if the link is in our DB, if it's in our DB, that means that we already scraped this card and then we don't have to go to the property show.

### does_prop_exists?(filtered_prop, time)
```filtered_prop``` is a hash of non-nil values of the prop hash previously filtered. 

We did that because sometimes, we can't have certain values, like ```area``` or ```surface``` and we don't want to check in our DB with 4 values with one equal to nil, it doesn't make sense.

But if we have only 2 non-nil values, we can't go to the property show, because it's too light to check in our DB a combinaison of only 2 values.

```time``` is an integer that determines a time frame range of properties that we have in our db. For example, if ```time = 4```, we will check all the properties that we inserted in our DB with the filtered_prop hash quadriptic/triptic from 4 days ago to today.

## et Voila !!!!! What? oh no it's not over
After all thoses checks, if go_to_props return ```true```, ONLY NOW we will go to the property show. But it's not over. 

## final_check_with_desc(hashed_property)

This is the last check to determine if we don"t have any duplicates by the description. 

We check only with a triptique of data if we have this property : ```surface```, ```area``` and ```price```

If it returns one or many properties, we check every property's description with the method desc_comparator.

The logic is quite complex, we remove every space, commas, dots, hyphen and encoded characters, and we check every sequence of 44 characters. If one matches the description of the property we just scraped, then it means that this is a duplicate. Therefore, NO INSERTION.

NB: We decided to remove the rooms_number from the final check, because sometimes agencies are uploading a property with a rooms_number, then they realize that they made a mistake, so they change the rooms_number, replublish it and we re-scrap it, making it a false positive (stupid agents).

## et voilaa... no not yet 
 
We check if it is a unwanted prop, so basically, given the description we now have, we look if the property is ```viager```, ```local commercial```,```bien déjà vendu```, ```bien sous compromis```, ```sous offre actuellement```, ```ehpad```, etc.

Aaaand we recheck if it's a fake property, because normally we have all the data we need to determine the square meter price.

After all thoses checks, we can insert a property.


# 

# If you want to scrap, be our guest
## Scraper Class

The Scraper Class is located to app/services/scrapers/scraper.rb

It doesn't take any parameters to initialize, but it is a parent class for every scraper we developped. 

All the methods are properly tested given our use cases, in spec/services/scrapers/.. .

## Arguments for Child Scrapers 

```ruby
@url
@source
@main_page_cls
@type
@waiting_cls
@multi_page
@page_nbr
@properties
@http_request
@http_type
@params
```
### Url
It is the url you want to scrap 

### Source
It is the name of the scraper you are creating, be creative, but consistent (ex: "SuperImmo")

### Main page cls (for Main Page Class)
This is the div of a card containing all the datas you want to extract. For example, if you want to scrap SuperImmo, their card is a division in a section, with a class name called "media-body"

So you'll initialize your scraper with "section > div.media-body".

If the card is a article with a class "property", you'll want to name this parameter "article.property". 

### Scraper Type
This is the type of scraper you want to use. There's 4 types 
- Static (if you want to fetch a static page)
- Captcha (if you want to fetch a page with recurring captchas)
- HTTPRequest (if you want to make a specific post request with parameters)
- Dynamic (if you need to load JavaScript, but it soon will be deprecated)

For all thos type, you have subtypes

### Multi Page (multi_page) & Page Number (page_nbr)
Multi Page is a boolean, by default it should be false. 
However, if it's true, you need to add a page_nbr to 1 or more, and changed the url you want to scrap with the explicit page in it.

For example, if you have a basic url "https://google.com/result/page-1" and you want to scrap the first 3 pages, this is how you'll declare those parameters
```ruby
@url = "https://google.com/result/page-[[PAGE_NUMBER]]" ##<- Without this, the scrapper won't work
@scraper_type = "Static"
@multi_page = true
@page_nbr = 3
```

### Properties
This is a parameters used for our test and for the object to render what we crave the most, whic h is properties. It is an Array of hashed.

You'll need to declare an empty array
```ruby
@properties = []
```

### HTTP TYPE
If you're using a scraper type of "HTTPRequest", then you'll need to fill in this parameter with 4 types :
- get_json (if you need to only extract a json from a website, then it won't call Nokogiri to parse HTML)
- post (if you need to make a post request to obtain an HTML response, then Nokogiri will parse the html response and you're good to go)
- post_json (if you need to make a post request to obtain a JSON response, then Nokogiri won't parse anything and you'll have a parse JSON, really handy)

### HTTPRequest
If you're using a scraper type of "HTTPRequest" with a "http_type" of post/post_json, you'll need to declare an array of two hashes. 
- The first index of the array is generally an empty hash, and is the header of the request.
- The second index of the array is the body of the request, and you can easily find the encoded parsed body in Firefox in the console > Network > Request transmission.

### Params
This argument is for a multiple scraper with the same code architecture. Basically, if we want to use the same code but for two different url, we pass a "params" argument, that will fetch a method that calls thos arguments in our DB. 



# That's it for now !

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
This app is the property of the DingDong™ team.