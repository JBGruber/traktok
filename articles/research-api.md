# Research API

TikTok’s [Research
API](https://developers.tiktok.com/products/research-api/), which was
made available to researchers in the US and Europe in 2023, offers three
endpoints, which are wrapped in three `traktok` functions:

1.  You can [search
    videos](https://developers.tiktok.com/doc/research-api-specs-query-videos)
    with `tt_search_api` or `tt_search`
2.  You can [get basic user
    information](https://developers.tiktok.com/doc/research-api-specs-query-user-info)
    with `tt_user_info_api` or `tt_user_info`
3.  You can [obtain all comments of a
    video](https://developers.tiktok.com/doc/research-api-specs-query-video-comments)
    with `tt_comments_api` or `tt_comments`
4.  You can [get the videos a user has
    liked](https://developers.tiktok.com/doc/research-api-specs-query-user-liked-videos)
    with `tt_user_liked_videos_api` or `tt_get_liked`
5.  You can [get the videos a user has
    reposted](https://developers.tiktok.com/doc/research-api-specs-query-user-reposted-videos)
    with `tt_user_reposted_api` or `tt_get_reposted`
6.  You can [get the videos a user has
    pinned](https://developers.tiktok.com/doc/research-api-specs-query-user-pinned-videos)
    with `tt_user_pinned_videos_api` or `tt_get_pinned`
7.  You can [get who a user is
    following](https://developers.tiktok.com/doc/research-api-specs-query-user-following)
    or [follows a
    user](https://developers.tiktok.com/doc/research-api-specs-query-user-following)
    with `tt_get_following`/`tt_get_follower` or
    `tt_user_following_api`/`tt_user_follower_api`

## Authentication

To get access to the Research API, you need to:

1.  [be eligible](https://developers.tiktok.com/products/research-api);
2.  [create a developer account](https://developers.tiktok.com/signup);
3.  and then apply for access to the research API:
    <https://developers.tiktok.com/application/research-api>

Once you have been approved and have your client key and client secret,
you can authenticate with:

``` r
library(traktok)
auth_research()
```

It is recommended that you run this function only once without
arguments, so that your key and secret can be entered through the pop up
mask and do not remain unencrypted in your R history or a script. The
function then runs through authentication for you and saves the
resulting token encrypted on your hard drive. Just run it again in case
your credentials change.

## Usage

### Search Videos

TikTok uses a fine-grained, yet complicated [query
syntax](https://developers.tiktok.com/doc/research-api-specs-query-videos#query).
For convenience, a query is constructed internally when you search with
a key phrase directly:

``` r
tt_query_videos("#rstats", max_pages = 2L)
#> 
ℹ Making initial request

✔ Making initial request [774ms]
#> 
ℹ Parsing data

✔ Parsing data [177ms]
#> ── search id: NA ───────────────────────────────────────
#> # A tibble: 0 × 13
#> # ℹ 13 variables: video_id <lgl>, author_name <chr>,
#> #   view_count <int>, comment_count <int>,
#> #   share_count <int>, like_count <int>,
#> #   region_code <chr>, create_time <dttm>,
#> #   effect_ids <list>, music_id <chr>,
#> #   video_description <chr>, hashtag_names <list>,
#> #   voice_to_text <chr>
```

This will match your keyword or phrase against keywords and hashtags and
return up to 200 results (each page has 100 results and 2 pages are
requested by default) from today and yesterday. Every whitespace is
treated as an AND operator. To extend the data range, you can set a
start and end (which can be a maximum of 30 days apart, but there is no
limit how far you can go back):

``` r
tt_query_videos("#rstats",
                max_pages = 2L,
                start_date = as.Date("2023-11-01"),
                end_date = as.Date("2023-11-29"))
#> 
ℹ Making initial request

✔ Making initial request [2s]
#> 
ℹ Parsing data

✔ Parsing data [63ms]
#> ── search id: 7423432753447932974 ──────────────────────
#> # A tibble: 19 × 13
#>    video_id         author_name view_count comment_count
#>    <chr>            <chr>            <int>         <int>
#>  1 730689385329705… statistics…        909             4
#>  2 730630774458222… learningca…       1104            11
#>  3 730501447636800… picanumeros       4645             8
#>  4 730297066790799… smooth.lea…      98717            17
#>  5 730247037950160… statistics…        508             0
#>  6 730097749816510… statistics…      27387             1
#>  7 730093147605973… rigochando        2603             4
#>  8 730092229522312… elartedeld…        765             0
#>  9 729998705941704… statistics…       1110             1
#> 10 729965751681473… rigochando         905             4
#> 11 729934294487885… rigochando         555             0
#> 12 729896668413454… rigochando        1312             1
#> 13 729691148659145… biofreelan…      19758             7
#> 14 729691148625178… biofreelan…       5763             1
#> 15 729691147878174… biofreelan…       1019             3
#> 16 729668885660947… mrpecners          657             2
#> 17 729651863537426… l_a_kelly          514             5
#> 18 729649864535081… mrpecners          373             0
#> 19 729628884337898… casaresfel…        274             0
#> # ℹ 9 more variables: share_count <int>,
#> #   like_count <int>, region_code <chr>,
#> #   create_time <dttm>, effect_ids <list>,
#> #   music_id <chr>, video_description <chr>,
#> #   hashtag_names <list>, voice_to_text <chr>
```

As said, the query syntax that TikTok uses is a little complicated, as
you can use AND, OR and NOT boolean operators on a number of fields
(`"create_date"`, `"username"`, `"region_code"`, `"video_id"`,
`"hashtag_name"`, `"keyword"`, `"music_id"`, `"effect_id"`, and
`"video_length"`):

| Operator | Results are returned if…                 |
|----------|------------------------------------------|
| AND      | …all specified conditions are met        |
| OR       | …any of the specified conditions are met |
| NOT      | …the not conditions are not met          |

To make this easier to use, `traktok` uses a tidyverse style approach to
building queries. For example, to get to the same query that matches
\#rstats against keywords and hashtags, you need to build the query like
this:

``` r
query() |>                                # start by using query()
  query_or(field_name = "hashtag_name",   # add an OR condition on the hashtag field
           operation = "IN",              # the value should be IN the list of hashtags
           field_values = "rstats") |>    # the hashtag field does not accept the #-symbol
  query_or(field_name = "keyword",        # add another OR condition
           operation = "IN",
           field_values = "#rstats")
#> S3<traktok_query>
#> └─or: <list>
#>   ├─<list>
#>   │ ├─field_name: "hashtag_name"
#>   │ ├─operation: "IN"
#>   │ └─field_values: <list>
#>   │   └─"rstats"
#>   └─<list>
#>     ├─field_name: "keyword"
#>     ├─operation: "IN"
#>     └─field_values: <list>
#>       └─"#rstats"
```

If \#rstats is found in either the hashtag or keywords of a video, that
video is then returned. Besides checking for `EQ`ual, you can also use
one of the other operations:

| Operation | Results are returned if field_values are…       |
|-----------|-------------------------------------------------|
| EQ        | equal to the value in the field                 |
| IN        | equal to a value in the field                   |
| GT        | greater than the value in the field             |
| GTE       | greater than or equal to the value in the field |
| LT        | lower than the value in the field               |
| LTE       | lower than or equal to the value in the field   |

This makes building queries relatively complex, but allows for
fine-grained searches in the TikTok data:

``` r
search_df <- query() |>
  query_and(field_name = "region_code",
            operation = "IN",
            field_values = c("JP", "US")) |>
  query_or(field_name = "hashtag_name",
            operation = "EQ", # rstats is the only hashtag
            field_values = "rstats") |>
  query_or(field_name = "keyword",
           operation = "IN", # rstats is one of the keywords
           field_values = "rstats") |>
  query_not(operation = "EQ",
            field_name = "video_length",
            field_values = "SHORT") |>
  tt_search_api(start_date = as.Date("2023-11-01"),
                end_date = as.Date("2023-11-29"))
#> 
ℹ Making initial request

✔ Making initial request [1.1s]
#> 
ℹ Parsing data

✔ Parsing data [59ms]
search_df
#> ── search id: 7423432753447965742 ──────────────────────
#> # A tibble: 2 × 13
#>   video_id          author_name view_count comment_count
#>   <chr>             <chr>            <int>         <int>
#> 1 7296688856609475… mrpecners          657             2
#> 2 7296498645350812… mrpecners          373             0
#> # ℹ 9 more variables: share_count <int>,
#> #   like_count <int>, region_code <chr>,
#> #   create_time <dttm>, effect_ids <list>,
#> #   music_id <chr>, video_description <chr>,
#> #   hashtag_names <list>, voice_to_text <chr>
```

This will return videos posted in the US or Japan, that have rstats as
the only hashtag or as one of the keywords and have a length of `"MID"`,
`"LONG"`, or `"EXTRA_LONG"`.[¹](#fn1)

### Get User Information

There is not really much to getting basic user info, but this is how you
can do it:

``` r
tt_user_info_api(username = c("tiktok", "https://www.tiktok.com/@statisticsglobe"))
#> 
ℹ Getting user tiktok

✔ Got user tiktok [508ms]
#> 
ℹ Getting user statisticsglobe

✔ Got user statisticsglobe [518ms]
#> # A tibble: 2 × 8
#>   is_verified likes_count video_count avatar_url        
#>   <lgl>             <int>       <int> <chr>             
#> 1 TRUE          330919903        1073 https://p16-pu-si…
#> 2 FALSE              1660          92 https://p16-sign-…
#> # ℹ 4 more variables: bio_description <chr>,
#> #   display_name <chr>, follower_count <int>,
#> #   following_count <int>
```

If you wish to return the videos of a user, your can use the search
again:

``` r
query() |>
  query_and(field_name = "username",
            operation = "EQ",
            field_values = "statisticsglobe") |>
  tt_search_api(start_date = as.Date("2023-11-01"),
                end_date = as.Date("2023-11-29"))
#> 
ℹ Making initial request

✔ Making initial request [872ms]
#> 
ℹ Parsing data

✔ Parsing data [65ms]
#> ── search id: 7423432753448064046 ──────────────────────
#> # A tibble: 5 × 13
#>   video_id          author_name view_count comment_count
#>   <chr>             <chr>            <int>         <int>
#> 1 7306893853297052… statistics…        909             4
#> 2 7302470379501604… statistics…        508             0
#> 3 7300977498165103… statistics…      27387             1
#> 4 7299987059417042… statistics…       1110             1
#> 5 7297389484524506… statistics…        538             2
#> # ℹ 9 more variables: share_count <int>,
#> #   like_count <int>, region_code <chr>,
#> #   create_time <dttm>, effect_ids <list>,
#> #   music_id <chr>, video_description <chr>,
#> #   hashtag_names <list>, voice_to_text <chr>
```

You can also find the videos a user has pinned to the top of their page:

``` r
tt_user_pinned_videos_api(c("tiktok", "https://www.tiktok.com/@smooth.learning.c"))
#> 
ℹ Getting user tiktok

✖ Getting user tiktok [367ms]
#> 
ℹ Getting user smooth.learning.c

✔ Got user smooth.learning.c [571ms]
#> # A tibble: 1 × 14
#>   pinned_by_user    create_time id      is_stem_verified
#>   <chr>                   <int> <chr>   <lgl>           
#> 1 smooth.learning.c  1690255097 725959… FALSE           
#> # ℹ 10 more variables: region_code <chr>,
#> #   video_duration <int>, view_count <int>,
#> #   video_description <chr>, comment_count <int>,
#> #   hashtag_names <list>, like_count <int>,
#> #   music_id <chr>, share_count <int>, username <chr>
```

To find out what a user has liked, you can use:

``` r
tt_get_liked("jbgruber")
#> 
ℹ Getting user jbgruber

✔ Got user jbgruber [1.5s]
#> # A tibble: 98 × 14
#>    id             username create_time video_description
#>    <chr>          <chr>          <int> <chr>            
#>  1 7355902326877… america…  1712679503 "Stitch with @Mr…
#>  2 7268078476102… carterp…  1692231398 "Are you going t…
#>  3 7419692903460… okbrune…  1727531892 "Die ganze Wahrh…
#>  4 7405633113835… funny_s…  1724258332 "#fyp #fypシ #fu…
#>  5 7398532172048… lib0160…  1722605019 "Me and ChatGPT …
#>  6 7364763547038… vquasch…  1714742648 "Einige Medien u…
#>  7 7346577913858… ct_3003   1710508473 "Diese Platine f…
#>  8 7379856141972… lizthed…  1718256663 "Replying to @Ar…
#>  9 7415189182865… felixba…  1726483284 "Es geht wieder …
#> 10 7422673042553… grueneb…  1728225752 "Was Söder uns e…
#> # ℹ 88 more rows
#> # ℹ 10 more variables: region_code <chr>,
#> #   video_duration <int>, view_count <int>,
#> #   like_count <int>, comment_count <int>,
#> #   share_count <int>, music_id <chr>,
#> #   hashtag_names <list>, is_stem_verified <lgl>,
#> #   liked_by_user <chr>
```

Note, that making likes public is an opt-in feature of TikTok and almost
nobody has this enabled, so it will give you a lot of warning…

What we can usually get is the information who a user follows:

``` r
tt_user_following_api(username = "jbgruber")
#> 
ℹ Getting user jbgruber

✔ Got user jbgruber [296ms]
#> # A tibble: 19 × 3
#>    display_name          username         following_user
#>    <chr>                 <chr>            <chr>         
#>  1 SohoBrody             rudeboybrody     jbgruber      
#>  2 Last Week Tonight     lastweektonight… jbgruber      
#>  3 schlantologie         schlantologie    jbgruber      
#>  4 Alex Falcone          alex_falcone     jbgruber      
#>  5 dadNRG                dadnrg           jbgruber      
#>  6 Einfach Genial Tictok user22690086508… jbgruber      
#>  7 noir_concrete_studio  noir_concrete_s… jbgruber      
#>  8 fatDumbledore         fatdumbledore13… jbgruber      
#>  9 fragdenstaat.de       fragdenstaat.de  jbgruber      
#> 10 Erikadbka             erikadbka        jbgruber      
#> 11 BÜNDNIS 90/DIE GRÜNEN diegruenen       jbgruber      
#> 12 lagedernationclips    lagedernationcl… jbgruber      
#> 13 Alexandra Ils         kitty.fantastico jbgruber      
#> 14 future infinitive ☸️   lizthedeveloper  jbgruber      
#> 15 Tim Achtermeyer       achtermeyer      jbgruber      
#> 16 Jay Foreman           jayforeman       jbgruber      
#> 17 Cosmo                 whereiswanda     jbgruber      
#> 18 Tim Walz              timwalz          jbgruber      
#> 19 Shahak Shapira        shahakshapira    jbgruber
```

And who they are followed by:

``` r
tt_user_follower_api("https://www.tiktok.com/@tiktok")
#> 
ℹ Getting user tiktok

✔ Got user tiktok [442ms]
#> # A tibble: 90 × 3
#>    username           display_name     following_user
#>    <chr>              <chr>            <chr>         
#>  1 galbruwt           reeyyp           tiktok        
#>  2 user5235623178011  👑কিং রানা 🥀    tiktok        
#>  3 rokyevay07         👑Rokye Vay👑    tiktok        
#>  4 babyylious08       babyylious08     tiktok        
#>  5 user8283823357     hd❤️‍🩹jaan❤️‍🩹hi❤️‍🩹❤️  tiktok        
#>  6 user45628309141722 سامي             tiktok        
#>  7 nu.th085           Nâu Thị          tiktok        
#>  8 halimeysll         halimeysll       tiktok        
#>  9 taru.tristiyanto   Taru Tristiyanto tiktok        
#> 10 vng.lan.hng09      Vương Lan Hường  tiktok        
#> # ℹ 80 more rows
```

### Obtain all Comments of a Video

There is again, not much to talk about when it comes to the comments
API. You need to supply a video ID, which you either have already:

``` r
tt_comments_api(video_id = "7302470379501604128")
#> 
ℹ Making initial request

✔ Making initial request [4.9s]
#> 
ℹ Parsing data

✔ Parsing data [68ms]
#> ── search id:  ─────────────────────────────────────────
#> # A tibble: 1 × 7
#>   create_time id            like_count parent_comment_id
#>         <int> <chr>              <int> <chr>            
#> 1  1700243424 730248974199…          0 7302470379501604…
#> # ℹ 3 more variables: reply_count <int>, text <chr>,
#> #   video_id <chr>
```

Or you got it from a search:

``` r
tt_comments_api(video_id = search_df$video_id[1])
#> 
ℹ Making initial request

✔ Making initial request [4.8s]
#> 
ℹ Parsing data

✔ Parsing data [61ms]
#> ── search id:  ─────────────────────────────────────────
#> # A tibble: 2 × 7
#>   create_time id            like_count parent_comment_id
#>         <int> <chr>              <int> <chr>            
#> 1  1698893206 729669068138…          1 7296688856609475…
#> 2  1698893251 729669083429…          0 7296690681388204…
#> # ℹ 3 more variables: reply_count <int>, text <chr>,
#> #   video_id <chr>
```

Or you let the function extract if from a URL to a video:

``` r
tt_comments_api(video_id = "https://www.tiktok.com/@nicksinghtech/video/7195762648716152107?q=%23rstats")
#> 
ℹ Making initial request

✔ Making initial request [5.9s]
#> 
ℹ Parsing data

✔ Parsing data [58ms]
#> ── search id:  ─────────────────────────────────────────
#> # A tibble: 96 × 7
#>    text            video_id create_time id    like_count
#>    <chr>           <chr>          <int> <chr>      <int>
#>  1 You gotta know… 7195762…  1675394834 7195…        314
#>  2 R is the goat … 7195762…  1675457114 7196…        232
#>  3 Ppl who like E… 7195762…  1675458796 7196…        177
#>  4 Fair but doesn… 7195762…  1675395061 7195…        166
#>  5 babe RStudio i… 7195762…  1675624739 7196…         71
#>  6 Excel is the b… 7195762…  1675465779 7196…         71
#>  7 NOT THE SAS SL… 7195762…  1675494738 7196…         27
#>  8 I won't take t… 7195762…  1675691471 7197…         17
#>  9 No love for ST… 7195762…  1675656122 7196…         16
#> 10 I use SAS 🫡    7195762…  1675440749 7195…         16
#> # ℹ 86 more rows
#> # ℹ 2 more variables: parent_comment_id <chr>,
#> #   reply_count <int>
```

And that is essentially it. Note, that if you find the functionality of
the Research API lacking, there is nothing that keeps you from using the
unofficial API functions.

## Dealing with rate limits and continuing old searches

At the moment of writing this vignette, the TikTok rate limits the
Research API as follows:

> Currently, the daily limit is set at 1000 requests per day, allowing
> you to obtain up to 100,000 records per day across our APIs. (Video
> and Comments API can return 100 records per request). The daily quota
> gets reset at 12 AM UTC.
> \[[Source](https://developers.tiktok.com/doc/research-api-faq?enter_method=left_navigation)\]

Depending on what you would like to do, this might not be enough for
you. In this case, you can actually save a search and pick it back up
after the reset. To facilitate this, search result objects contain two
extra pieces of information in the attributes:

``` r
search_df <- query() |>
  query_and(field_name = "region_code",
            operation = "IN",
            field_values = c("JP", "US")) |>
  tt_search_api(start_date = as.Date("2023-11-01"),
                end_date = as.Date("2023-11-29"),
                max_pages = 1)
#> 
ℹ Making initial request

✔ Making initial request [2.4s]
#> 
ℹ Parsing data

✔ Parsing data [71ms]

attr(search_df, "search_id")
#> [1] "7423432753448096814"
attr(search_df, "cursor")
#> [1] 100
```

When you want to continue this search, whether because of rate limit or
because you decided you want more results, you can do so by providing
`search_id` and `cursor` to `tt_search_api`. If your search was cut
short by the rate limit or another issue, you can retrieve the results
already received with `search_df <- last_query()`. `search_df` will in
both cases contain the relevant `search_id` and `cursor` in the
attributes:

``` r
search_df2 <- query() |>
  query_and(field_name = "region_code",
            operation = "IN",
            field_values = c("JP", "US")) |>
  tt_search_api(start_date = as.Date("2023-11-01"),
                end_date = as.Date("2023-11-29"),

                # this part is new
                start_cursor = attr(search_df, "cursor"),
                search_id = attr(search_df, "search_id"),
                ####
                max_pages = 1)
#> 
ℹ Making initial request

✔ Making initial request [5.1s]
#> 
ℹ Parsing data

✔ Parsing data [21ms]
attr(search_df2, "search_id")
#> [1] "7336340473470063662"
attr(search_df2, "cursor")
#> [1] 200
```

Note that the cursor is not equal to how many videos you got before, as
the API also counts videos that are “deleted/marked as private by users
etc.” \[See `max_count` in [Query
Videos](https://developers.tiktok.com/doc/research-api-specs-query-videos)\].

------------------------------------------------------------------------

1.  See
    <https://developers.tiktok.com/doc/research-api-specs-query-videos#condition_fields>
    for possible values of each field.
