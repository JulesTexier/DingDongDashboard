# Ding Dong and its amazing scraping app

Ahoï fellow scraper, if you're looking at this README, it is probably because you're wondering what the heck is going out with all this ScraperFramework Thingy. 

No worries, here at Ding Dong ™, we like to document every step we take every once in a while (basically when things get out of hands with tons of methods, like right now basically).

This documentation will explain how we can make a beautiful scraper with the methods we developped. It's not rocket science, don't worry.

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