
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metatargetr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/metatargetr)](https://CRAN.R-project.org/package=metatargetr)
<!-- badges: end -->

The goal of metatargetr is to …

## Installation

You can install the development version of metatargetr like so:

``` r
remotes::install_github("favstats/metatargetr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(metatargetr)
## basic example code
```

## Get Targeting criteria (Last 30 Days)

The following code retrieves the targeting criteria used by the Social
Democrats in Denmark in the last 30 days. Just put in the right Page ID.

``` r
get_targeting("41459763029", timeframe = "LAST_30_DAYS")
#> Warning: Outer names are only allowed for unnamed scalar atomic inputs
#>                                    value num_ads total_spend_pct
#> 1                                    All     117    1.0000000000
#> 2                                  Women       0    0.0000000000
#> 3                                    Men       0    0.0000000000
#> 4                                 Danish       8    0.0518197767
#> 5                       Esbjerg, Denmark       3    0.0105857352
#> 6                         Ishøj, Denmark       1    0.0104232113
#> 7                          6360, Denmark       2    0.0137896480
#> 8                                Denmark      84    0.7789614203
#> 9                          5762, Denmark       1    0.0130290141
#> 10     Albertslund Municipality, Denmark       1    0.0104232113
#> 11                         9800, Denmark       1    0.0109714462
#> 12                      Aalborg, Denmark       1    0.0104232113
#> 13     Haderslev, Sonderjylland, Denmark       1    0.0105346615
#> 14                         3220, Denmark       1    0.0062023840
#> 15                       Aarhus, Denmark       3    0.0172195881
#> 16                       Tårnby, Denmark       1    0.0052116057
#> 17                     Ballerup, Denmark       1    0.0104232113
#> 18                       Aarhus, Denmark       1    0.0013029014
#> 19                      Aalborg, Denmark       1    0.0042357846
#> 20          Herlev Municipality, Denmark       1    0.0104232113
#> 21                     Helsinge, Denmark       1    0.0003816198
#> 22                         9330, Denmark       1    0.0023173144
#> 23                         3390, Denmark       1    0.0062023840
#> 24                         5771, Denmark       1    0.0130290141
#> 25                         5892, Denmark       1    0.0130290141
#> 26                         5700, Denmark       2    0.0237908235
#> 27                         5874, Denmark       1    0.0130290141
#> 28                         6700, Denmark       3    0.0105857352
#> 29                         6705, Denmark       3    0.0105857352
#> 30                         3320, Denmark       1    0.0062023840
#> 31                       Holbæk, Denmark       1    0.0052116057
#> 32                         6715, Denmark       3    0.0105857352
#> 33                         6622, Denmark       1    0.0023170538
#> 34                         8881, Denmark       1    0.0075640463
#> 35                         6261, Denmark       2    0.0137896480
#> 36                         2980, Denmark       1    0.0023037382
#> 37                         3650, Denmark       1    0.0103791472
#> 38                         5882, Denmark       1    0.0130290141
#> 39                         8620, Denmark       1    0.0075640463
#> 40                         5610, Denmark       1    0.0023195033
#> 41                         3050, Denmark       1    0.0023037382
#> 42                         5884, Denmark       1    0.0130290141
#> 43                         6792, Denmark       2    0.0137896480
#> 44                         6780, Denmark       2    0.0137896480
#> 45                         6100, Denmark       1    0.0105346615
#> 46                         3630, Denmark       1    0.0103791472
#> 47               Zealand Region, Denmark       1    0.0002879152
#> 48                         3370, Denmark       1    0.0062023840
#> 49                         6710, Denmark       3    0.0105857352
#> 50                         6372, Denmark       2    0.0137896480
#> 51                         6280, Denmark       2    0.0137896480
#> 52                         3550, Denmark       1    0.0103791472
#> 53                         3600, Denmark       1    0.0103791472
#> 54                         6270, Denmark       2    0.0137896480
#> 55                         3480, Denmark       1    0.0023037382
#> 56                      Randers, Denmark       1    0.0104232113
#> 57                         6240, Denmark       2    0.0137896480
#> 58                       Viborg, Denmark       1    0.0108958779
#> 59                         5881, Denmark       1    0.0130290141
#> 60                         8883, Denmark       1    0.0075640463
#> 61                         5883, Denmark       1    0.0130290141
#> 62                         7190, Denmark       1    0.0023170538
#> 63                         6623, Denmark       1    0.0023170538
#> 64                         8654, Denmark       1    0.0075640463
#> 65                         5772, Denmark       1    0.0130290141
#> 66                         8670, Denmark       1    0.0075640463
#> 67                         7184, Denmark       1    0.0023170538
#> 68                         8600, Denmark       1    0.0075640463
#> 69                         2990, Denmark       1    0.0023037382
#> 70                         8653, Denmark       1    0.0075640463
#> 71                         8641, Denmark       1    0.0075640463
#> 72                         6560, Denmark       1    0.0105346615
#> 73                         8840, Denmark       1    0.0075640463
#> 74                         8632, Denmark       1    0.0075640463
#> 75                         8882, Denmark       1    0.0075640463
#> 76                         7000, Denmark       1    0.0106769123
#> 77                         7250, Denmark       1    0.0023170538
#> 78                         8680, Denmark       1    0.0075640463
#> 79                         6500, Denmark       1    0.0105346615
#> 80                         3360, Denmark       1    0.0062023840
#> 81                         3300, Denmark       1    0.0062023840
#> 82                         6541, Denmark       1    0.0105346615
#> 83                         8643, Denmark       1    0.0075640463
#> 84                         4050, Denmark       1    0.0103791472
#> 85                         3310, Denmark       1    0.0062023840
#> 86                         9740, Denmark       1    0.0023173144
#> 87                         9700, Denmark       1    0.0023173144
#> 88                         6510, Denmark       1    0.0105346615
#> 89                         9320, Denmark       1    0.0023173144
#> 90                         9340, Denmark       1    0.0023173144
#> 91                                    13       0    0.0000000000
#> 92                                    14       0    0.0000000000
#> 93                                    15       0    0.0000000000
#> 94                                    16       0    0.0000000000
#> 95                                    17       0    0.0000000000
#> 96                                    18      94    0.6829805558
#> 97                                    19      94    0.6829805558
#> 98                                    20      94    0.6829805558
#> 99                                    21      94    0.6829805558
#> 100                                   22      94    0.6829805558
#> 101                                   23      94    0.6829805558
#> 102                                   24      94    0.6829805558
#> 103                                   25      94    0.6829805558
#> 104                                   26      94    0.6829805558
#> 105                                   27      94    0.6829805558
#> 106                                   28      94    0.6829805558
#> 107                                   29      94    0.6829805558
#> 108                                   30      94    0.6829805558
#> 109                                   31      94    0.6829805558
#> 110                                   32      94    0.6829805558
#> 111                                   33      94    0.6829805558
#> 112                                   34      94    0.6829805558
#> 113                                   35      94    0.6829805558
#> 114                                   36      94    0.6829805558
#> 115                                   37      94    0.6829805558
#> 116                                   38      94    0.6829805558
#> 117                                   39      94    0.6829805558
#> 118                                   40     105    0.8421484646
#> 119                                   41      65    0.5785196794
#> 120                                   42      65    0.5785196794
#> 121                                   43      65    0.5785196794
#> 122                                   44      65    0.5785196794
#> 123                                   45      65    0.5785196794
#> 124                                   46      65    0.5785196794
#> 125                                   47      65    0.5785196794
#> 126                                   48      65    0.5785196794
#> 127                                   49      65    0.5785196794
#> 128                                   50      69    0.6298573565
#> 129                                   51      69    0.6298573565
#> 130                                   52      69    0.6298573565
#> 131                                   53      69    0.6298573565
#> 132                                   54      69    0.6298573565
#> 133                                   55      69    0.6298573565
#> 134                                   56      77    0.7363712147
#> 135                                   57      77    0.7363712147
#> 136                                   58      77    0.7363712147
#> 137                                   59      77    0.7363712147
#> 138                                   60      77    0.7363712147
#> 139                                   61      77    0.7363712147
#> 140                                   62      77    0.7363712147
#> 141                                   63      77    0.7363712147
#> 142                                   64      77    0.7363712147
#> 143                                  65+      58    0.4978178877
#> 144                   Lookalike audience       7    0.0230155971
#> 145                   Lookalike audience       0    0.0000000000
#> 146          Single-family detached home      40    0.2636287853
#> 147                 Vocational education      40    0.2636287853
#> 148                         Grøn Koncert       8    0.0793854183
#> 149                  Animal rescue group      19    0.2656817670
#> 150                       Apprenticeship      40    0.2636287853
#> 151                      Kevin Magnussen      14    0.1600687869
#> 152                                  DR2      48    0.3430142035
#> 153                         weber grills       7    0.0786860469
#> 154                               Børsen      25    0.2921082558
#> 155                             Circle K       6    0.0535549287
#> 156                            Isabellas      48    0.3430142035
#> 157                         Kindergarten      40    0.2636287853
#> 158                            Gardening      11    0.1591679088
#> 159                       Mortgage loans      63    0.5282141086
#> 160                                  DR3      19    0.2656817670
#> 161                         Eurowoman DK      40    0.2636287853
#> 162                             Circle K      15    0.1580714651
#> 163                                DR P1      48    0.3430142035
#> 164                                Zizzi       8    0.0793854183
#> 165                                Bilka       7    0.0786860469
#> 166               Dancing with the Stars       7    0.0786860469
#> 167                                DR P3      40    0.2636287853
#> 168                              Pension       8    0.1065138582
#> 169                              Camping      47    0.3423148321
#> 170                   Silvan Byggemarked      11    0.1591679088
#> 171                              Finance      72    0.6344230879
#> 172       Louisiana Museum of Modern Art      40    0.2636287853
#> 173                        Skateboarding       8    0.0793854183
#> 174          Single-family detached home      11    0.1591679088
#> 175                                  BMW       8    0.0793854183
#> 176                               Lurpak       8    0.0793854183
#> 177                               School      40    0.2636287853
#> 178                              Camping      14    0.1600687869
#> 179                      Kevin Magnussen      15    0.1580714651
#> 180                          Health care      16    0.1858992765
#> 181                                  Bus       6    0.0535549287
#> 182                      Familie Journal       8    0.0793854183
#> 183                             Veganism      32    0.3979227426
#> 184                           Greenhouse      14    0.1600687869
#> 185                          Video games       8    0.0793854183
#> 186                                House      11    0.1591679088
#> 187                      Filling station       6    0.0535549287
#> 188                            Eurosport       8    0.0793854183
#> 189                                  DR2       7    0.0786860469
#> 190                         Eurowoman DK      14    0.1600687869
#> 191                            Saxo Bank       7    0.0786860469
#> 192                                Skole       7    0.1053983401
#> 193       Louisiana Museum of Modern Art       7    0.0786860469
#> 194                              Ecology       7    0.0786860469
#> 195                              Climate       7    0.0786860469
#> 196                         weber grills       8    0.1065138582
#> 197                  Natural environment       7    0.0786860469
#> 198                   Matas (drug store)       8    0.0793854183
#> 199                              Ecology       6    0.0535549287
#> 200                           Motherhood       8    0.0793854183
#> 201                             Pedagogy       8    0.0793854183
#> 202                  Animal rescue group       6    0.0535549287
#> 203                                DR P1       7    0.0786860469
#> 204                      ALT for damerne      14    0.1600687869
#> 205                                 Lidl       7    0.0786860469
#> 206               Dancing with the Stars       6    0.0535549287
#> 207                                Bilka      11    0.1591679088
#> 208 The Fast and the Furious (2001 film)       8    0.0793854183
#> 209                       Premier League       8    0.0793854183
#> 210                      Filling station       7    0.0786860469
#> 211                            Preschool       7    0.1053983401
#> 212                     Danish Superliga       6    0.0535549287
#> 213                              Cruises       7    0.0786860469
#> 214                                 JYSK       6    0.0535549287
#> 215                                  RVs       7    0.0786860469
#> 216                   Investment banking       8    0.0793854183
#> 217                              FlixBus      11    0.1591679088
#> 218                            Isabellas       6    0.0535549287
#> 219                           Greenhouse      11    0.1591679088
#> 220                              FlixBus       8    0.1065138582
#> 221                       Premier League       8    0.1065138582
#>                   type location_type num_obfuscated is_exclusion detailed_type
#> 1               gender          <NA>             NA           NA          <NA>
#> 2               gender          <NA>             NA           NA          <NA>
#> 3               gender          <NA>             NA           NA          <NA>
#> 4             language          <NA>             NA           NA          <NA>
#> 5             location          CITY              1        FALSE          <NA>
#> 6             location          TOWN              1        FALSE          <NA>
#> 7             location          zips              0        FALSE          <NA>
#> 8             location     countries              0        FALSE          <NA>
#> 9             location          zips              0        FALSE          <NA>
#> 10            location          TOWN              1        FALSE          <NA>
#> 11            location          zips              0        FALSE          <NA>
#> 12            location          CITY              0        FALSE          <NA>
#> 13            location          TOWN              1        FALSE          <NA>
#> 14            location          zips              0        FALSE          <NA>
#> 15            location          CITY              0        FALSE          <NA>
#> 16            location          TOWN              1        FALSE          <NA>
#> 17            location          TOWN              1        FALSE          <NA>
#> 18            location          CITY              1        FALSE          <NA>
#> 19            location          CITY              1        FALSE          <NA>
#> 20            location          CITY              1        FALSE          <NA>
#> 21            location          CITY              1        FALSE          <NA>
#> 22            location          zips              0        FALSE          <NA>
#> 23            location          zips              0        FALSE          <NA>
#> 24            location          zips              0        FALSE          <NA>
#> 25            location          zips              0        FALSE          <NA>
#> 26            location          zips              0        FALSE          <NA>
#> 27            location          zips              0        FALSE          <NA>
#> 28            location          zips              0        FALSE          <NA>
#> 29            location          zips              0        FALSE          <NA>
#> 30            location          zips              0        FALSE          <NA>
#> 31            location          CITY              0        FALSE          <NA>
#> 32            location          zips              0        FALSE          <NA>
#> 33            location          zips              0        FALSE          <NA>
#> 34            location          zips              0        FALSE          <NA>
#> 35            location          zips              0        FALSE          <NA>
#> 36            location          zips              0        FALSE          <NA>
#> 37            location          zips              0        FALSE          <NA>
#> 38            location          zips              0        FALSE          <NA>
#> 39            location          zips              0        FALSE          <NA>
#> 40            location          zips              0        FALSE          <NA>
#> 41            location          zips              0        FALSE          <NA>
#> 42            location          zips              0        FALSE          <NA>
#> 43            location          zips              0        FALSE          <NA>
#> 44            location          zips              0        FALSE          <NA>
#> 45            location          zips              0        FALSE          <NA>
#> 46            location          zips              0        FALSE          <NA>
#> 47            location       regions              0        FALSE          <NA>
#> 48            location          zips              0        FALSE          <NA>
#> 49            location          zips              0        FALSE          <NA>
#> 50            location          zips              0        FALSE          <NA>
#> 51            location          zips              0        FALSE          <NA>
#> 52            location          zips              0        FALSE          <NA>
#> 53            location          zips              0        FALSE          <NA>
#> 54            location          zips              0        FALSE          <NA>
#> 55            location          zips              0        FALSE          <NA>
#> 56            location          CITY              0        FALSE          <NA>
#> 57            location          zips              0        FALSE          <NA>
#> 58            location          CITY              0        FALSE          <NA>
#> 59            location          zips              0        FALSE          <NA>
#> 60            location          zips              0        FALSE          <NA>
#> 61            location          zips              0        FALSE          <NA>
#> 62            location          zips              0        FALSE          <NA>
#> 63            location          zips              0        FALSE          <NA>
#> 64            location          zips              0        FALSE          <NA>
#> 65            location          zips              0        FALSE          <NA>
#> 66            location          zips              0        FALSE          <NA>
#> 67            location          zips              0        FALSE          <NA>
#> 68            location          zips              0        FALSE          <NA>
#> 69            location          zips              0        FALSE          <NA>
#> 70            location          zips              0        FALSE          <NA>
#> 71            location          zips              0        FALSE          <NA>
#> 72            location          zips              0        FALSE          <NA>
#> 73            location          zips              0        FALSE          <NA>
#> 74            location          zips              0        FALSE          <NA>
#> 75            location          zips              0        FALSE          <NA>
#> 76            location          zips              0        FALSE          <NA>
#> 77            location          zips              0        FALSE          <NA>
#> 78            location          zips              0        FALSE          <NA>
#> 79            location          zips              0        FALSE          <NA>
#> 80            location          zips              0        FALSE          <NA>
#> 81            location          zips              0        FALSE          <NA>
#> 82            location          zips              0        FALSE          <NA>
#> 83            location          zips              0        FALSE          <NA>
#> 84            location          zips              0        FALSE          <NA>
#> 85            location          zips              0        FALSE          <NA>
#> 86            location          zips              0        FALSE          <NA>
#> 87            location          zips              0        FALSE          <NA>
#> 88            location          zips              0        FALSE          <NA>
#> 89            location          zips              0        FALSE          <NA>
#> 90            location          zips              0        FALSE          <NA>
#> 91                 age          <NA>             NA           NA          <NA>
#> 92                 age          <NA>             NA           NA          <NA>
#> 93                 age          <NA>             NA           NA          <NA>
#> 94                 age          <NA>             NA           NA          <NA>
#> 95                 age          <NA>             NA           NA          <NA>
#> 96                 age          <NA>             NA           NA          <NA>
#> 97                 age          <NA>             NA           NA          <NA>
#> 98                 age          <NA>             NA           NA          <NA>
#> 99                 age          <NA>             NA           NA          <NA>
#> 100                age          <NA>             NA           NA          <NA>
#> 101                age          <NA>             NA           NA          <NA>
#> 102                age          <NA>             NA           NA          <NA>
#> 103                age          <NA>             NA           NA          <NA>
#> 104                age          <NA>             NA           NA          <NA>
#> 105                age          <NA>             NA           NA          <NA>
#> 106                age          <NA>             NA           NA          <NA>
#> 107                age          <NA>             NA           NA          <NA>
#> 108                age          <NA>             NA           NA          <NA>
#> 109                age          <NA>             NA           NA          <NA>
#> 110                age          <NA>             NA           NA          <NA>
#> 111                age          <NA>             NA           NA          <NA>
#> 112                age          <NA>             NA           NA          <NA>
#> 113                age          <NA>             NA           NA          <NA>
#> 114                age          <NA>             NA           NA          <NA>
#> 115                age          <NA>             NA           NA          <NA>
#> 116                age          <NA>             NA           NA          <NA>
#> 117                age          <NA>             NA           NA          <NA>
#> 118                age          <NA>             NA           NA          <NA>
#> 119                age          <NA>             NA           NA          <NA>
#> 120                age          <NA>             NA           NA          <NA>
#> 121                age          <NA>             NA           NA          <NA>
#> 122                age          <NA>             NA           NA          <NA>
#> 123                age          <NA>             NA           NA          <NA>
#> 124                age          <NA>             NA           NA          <NA>
#> 125                age          <NA>             NA           NA          <NA>
#> 126                age          <NA>             NA           NA          <NA>
#> 127                age          <NA>             NA           NA          <NA>
#> 128                age          <NA>             NA           NA          <NA>
#> 129                age          <NA>             NA           NA          <NA>
#> 130                age          <NA>             NA           NA          <NA>
#> 131                age          <NA>             NA           NA          <NA>
#> 132                age          <NA>             NA           NA          <NA>
#> 133                age          <NA>             NA           NA          <NA>
#> 134                age          <NA>             NA           NA          <NA>
#> 135                age          <NA>             NA           NA          <NA>
#> 136                age          <NA>             NA           NA          <NA>
#> 137                age          <NA>             NA           NA          <NA>
#> 138                age          <NA>             NA           NA          <NA>
#> 139                age          <NA>             NA           NA          <NA>
#> 140                age          <NA>             NA           NA          <NA>
#> 141                age          <NA>             NA           NA          <NA>
#> 142                age          <NA>             NA           NA          <NA>
#> 143                age          <NA>             NA           NA          <NA>
#> 144 lookalike_audience          <NA>             NA        FALSE          <NA>
#> 145 lookalike_audience          <NA>             NA         TRUE          <NA>
#> 146           detailed          <NA>             NA         TRUE     INTERESTS
#> 147           detailed          <NA>             NA        FALSE     INTERESTS
#> 148           detailed          <NA>             NA         TRUE     INTERESTS
#> 149           detailed          <NA>             NA         TRUE     INTERESTS
#> 150           detailed          <NA>             NA        FALSE     INTERESTS
#> 151           detailed          <NA>             NA        FALSE     INTERESTS
#> 152           detailed          <NA>             NA         TRUE     INTERESTS
#> 153           detailed          <NA>             NA         TRUE     INTERESTS
#> 154           detailed          <NA>             NA         TRUE     INTERESTS
#> 155           detailed          <NA>             NA        FALSE     INTERESTS
#> 156           detailed          <NA>             NA        FALSE     INTERESTS
#> 157           detailed          <NA>             NA        FALSE     INTERESTS
#> 158           detailed          <NA>             NA        FALSE     INTERESTS
#> 159           detailed          <NA>             NA         TRUE     INTERESTS
#> 160           detailed          <NA>             NA         TRUE     INTERESTS
#> 161           detailed          <NA>             NA        FALSE     INTERESTS
#> 162           detailed          <NA>             NA         TRUE     INTERESTS
#> 163           detailed          <NA>             NA         TRUE     INTERESTS
#> 164           detailed          <NA>             NA        FALSE     INTERESTS
#> 165           detailed          <NA>             NA         TRUE     INTERESTS
#> 166           detailed          <NA>             NA         TRUE     INTERESTS
#> 167           detailed          <NA>             NA        FALSE     INTERESTS
#> 168           detailed          <NA>             NA        FALSE     INTERESTS
#> 169           detailed          <NA>             NA         TRUE     INTERESTS
#> 170           detailed          <NA>             NA        FALSE     INTERESTS
#> 171           detailed          <NA>             NA         TRUE     INTERESTS
#> 172           detailed          <NA>             NA         TRUE     INTERESTS
#> 173           detailed          <NA>             NA         TRUE     INTERESTS
#> 174           detailed          <NA>             NA        FALSE     INTERESTS
#> 175           detailed          <NA>             NA         TRUE     INTERESTS
#> 176           detailed          <NA>             NA        FALSE     INTERESTS
#> 177           detailed          <NA>             NA        FALSE     INTERESTS
#> 178           detailed          <NA>             NA        FALSE     INTERESTS
#> 179           detailed          <NA>             NA         TRUE     INTERESTS
#> 180           detailed          <NA>             NA        FALSE     INTERESTS
#> 181           detailed          <NA>             NA        FALSE     INTERESTS
#> 182           detailed          <NA>             NA        FALSE     INTERESTS
#> 183           detailed          <NA>             NA         TRUE     INTERESTS
#> 184           detailed          <NA>             NA         TRUE     INTERESTS
#> 185           detailed          <NA>             NA         TRUE     INTERESTS
#> 186           detailed          <NA>             NA        FALSE     INTERESTS
#> 187           detailed          <NA>             NA        FALSE     INTERESTS
#> 188           detailed          <NA>             NA         TRUE     INTERESTS
#> 189           detailed          <NA>             NA        FALSE     INTERESTS
#> 190           detailed          <NA>             NA         TRUE     INTERESTS
#> 191           detailed          <NA>             NA         TRUE     INTERESTS
#> 192           detailed          <NA>             NA        FALSE     INTERESTS
#> 193           detailed          <NA>             NA        FALSE     INTERESTS
#> 194           detailed          <NA>             NA        FALSE     INTERESTS
#> 195           detailed          <NA>             NA        FALSE     INTERESTS
#> 196           detailed          <NA>             NA        FALSE     INTERESTS
#> 197           detailed          <NA>             NA        FALSE     INTERESTS
#> 198           detailed          <NA>             NA        FALSE     INTERESTS
#> 199           detailed          <NA>             NA         TRUE     INTERESTS
#> 200           detailed          <NA>             NA        FALSE     INTERESTS
#> 201           detailed          <NA>             NA        FALSE     INTERESTS
#> 202           detailed          <NA>             NA        FALSE     INTERESTS
#> 203           detailed          <NA>             NA        FALSE     INTERESTS
#> 204           detailed          <NA>             NA         TRUE     INTERESTS
#> 205           detailed          <NA>             NA         TRUE     INTERESTS
#> 206           detailed          <NA>             NA        FALSE     INTERESTS
#> 207           detailed          <NA>             NA        FALSE     INTERESTS
#> 208           detailed          <NA>             NA         TRUE     INTERESTS
#> 209           detailed          <NA>             NA         TRUE     INTERESTS
#> 210           detailed          <NA>             NA         TRUE     INTERESTS
#> 211           detailed          <NA>             NA        FALSE     INTERESTS
#> 212           detailed          <NA>             NA        FALSE     INTERESTS
#> 213           detailed          <NA>             NA         TRUE     INTERESTS
#> 214           detailed          <NA>             NA        FALSE     INTERESTS
#> 215           detailed          <NA>             NA         TRUE     INTERESTS
#> 216           detailed          <NA>             NA         TRUE     INTERESTS
#> 217           detailed          <NA>             NA         TRUE     INTERESTS
#> 218           detailed          <NA>             NA         TRUE     INTERESTS
#> 219           detailed          <NA>             NA        FALSE     INTERESTS
#> 220           detailed          <NA>             NA        FALSE     INTERESTS
#> 221           detailed          <NA>             NA        FALSE     INTERESTS
#>             ds main_currency total_num_ads total_spend_formatted
#> 1   2022-10-17           DKK           117            DKK383,759
#> 2   2022-10-17           DKK           117            DKK383,759
#> 3   2022-10-17           DKK           117            DKK383,759
#> 4   2022-10-17           DKK           117            DKK383,759
#> 5   2022-10-17           DKK           117            DKK383,759
#> 6   2022-10-17           DKK           117            DKK383,759
#> 7   2022-10-17           DKK           117            DKK383,759
#> 8   2022-10-17           DKK           117            DKK383,759
#> 9   2022-10-17           DKK           117            DKK383,759
#> 10  2022-10-17           DKK           117            DKK383,759
#> 11  2022-10-17           DKK           117            DKK383,759
#> 12  2022-10-17           DKK           117            DKK383,759
#> 13  2022-10-17           DKK           117            DKK383,759
#> 14  2022-10-17           DKK           117            DKK383,759
#> 15  2022-10-17           DKK           117            DKK383,759
#> 16  2022-10-17           DKK           117            DKK383,759
#> 17  2022-10-17           DKK           117            DKK383,759
#> 18  2022-10-17           DKK           117            DKK383,759
#> 19  2022-10-17           DKK           117            DKK383,759
#> 20  2022-10-17           DKK           117            DKK383,759
#> 21  2022-10-17           DKK           117            DKK383,759
#> 22  2022-10-17           DKK           117            DKK383,759
#> 23  2022-10-17           DKK           117            DKK383,759
#> 24  2022-10-17           DKK           117            DKK383,759
#> 25  2022-10-17           DKK           117            DKK383,759
#> 26  2022-10-17           DKK           117            DKK383,759
#> 27  2022-10-17           DKK           117            DKK383,759
#> 28  2022-10-17           DKK           117            DKK383,759
#> 29  2022-10-17           DKK           117            DKK383,759
#> 30  2022-10-17           DKK           117            DKK383,759
#> 31  2022-10-17           DKK           117            DKK383,759
#> 32  2022-10-17           DKK           117            DKK383,759
#> 33  2022-10-17           DKK           117            DKK383,759
#> 34  2022-10-17           DKK           117            DKK383,759
#> 35  2022-10-17           DKK           117            DKK383,759
#> 36  2022-10-17           DKK           117            DKK383,759
#> 37  2022-10-17           DKK           117            DKK383,759
#> 38  2022-10-17           DKK           117            DKK383,759
#> 39  2022-10-17           DKK           117            DKK383,759
#> 40  2022-10-17           DKK           117            DKK383,759
#> 41  2022-10-17           DKK           117            DKK383,759
#> 42  2022-10-17           DKK           117            DKK383,759
#> 43  2022-10-17           DKK           117            DKK383,759
#> 44  2022-10-17           DKK           117            DKK383,759
#> 45  2022-10-17           DKK           117            DKK383,759
#> 46  2022-10-17           DKK           117            DKK383,759
#> 47  2022-10-17           DKK           117            DKK383,759
#> 48  2022-10-17           DKK           117            DKK383,759
#> 49  2022-10-17           DKK           117            DKK383,759
#> 50  2022-10-17           DKK           117            DKK383,759
#> 51  2022-10-17           DKK           117            DKK383,759
#> 52  2022-10-17           DKK           117            DKK383,759
#> 53  2022-10-17           DKK           117            DKK383,759
#> 54  2022-10-17           DKK           117            DKK383,759
#> 55  2022-10-17           DKK           117            DKK383,759
#> 56  2022-10-17           DKK           117            DKK383,759
#> 57  2022-10-17           DKK           117            DKK383,759
#> 58  2022-10-17           DKK           117            DKK383,759
#> 59  2022-10-17           DKK           117            DKK383,759
#> 60  2022-10-17           DKK           117            DKK383,759
#> 61  2022-10-17           DKK           117            DKK383,759
#> 62  2022-10-17           DKK           117            DKK383,759
#> 63  2022-10-17           DKK           117            DKK383,759
#> 64  2022-10-17           DKK           117            DKK383,759
#> 65  2022-10-17           DKK           117            DKK383,759
#> 66  2022-10-17           DKK           117            DKK383,759
#> 67  2022-10-17           DKK           117            DKK383,759
#> 68  2022-10-17           DKK           117            DKK383,759
#> 69  2022-10-17           DKK           117            DKK383,759
#> 70  2022-10-17           DKK           117            DKK383,759
#> 71  2022-10-17           DKK           117            DKK383,759
#> 72  2022-10-17           DKK           117            DKK383,759
#> 73  2022-10-17           DKK           117            DKK383,759
#> 74  2022-10-17           DKK           117            DKK383,759
#> 75  2022-10-17           DKK           117            DKK383,759
#> 76  2022-10-17           DKK           117            DKK383,759
#> 77  2022-10-17           DKK           117            DKK383,759
#> 78  2022-10-17           DKK           117            DKK383,759
#> 79  2022-10-17           DKK           117            DKK383,759
#> 80  2022-10-17           DKK           117            DKK383,759
#> 81  2022-10-17           DKK           117            DKK383,759
#> 82  2022-10-17           DKK           117            DKK383,759
#> 83  2022-10-17           DKK           117            DKK383,759
#> 84  2022-10-17           DKK           117            DKK383,759
#> 85  2022-10-17           DKK           117            DKK383,759
#> 86  2022-10-17           DKK           117            DKK383,759
#> 87  2022-10-17           DKK           117            DKK383,759
#> 88  2022-10-17           DKK           117            DKK383,759
#> 89  2022-10-17           DKK           117            DKK383,759
#> 90  2022-10-17           DKK           117            DKK383,759
#> 91  2022-10-17           DKK           117            DKK383,759
#> 92  2022-10-17           DKK           117            DKK383,759
#> 93  2022-10-17           DKK           117            DKK383,759
#> 94  2022-10-17           DKK           117            DKK383,759
#> 95  2022-10-17           DKK           117            DKK383,759
#> 96  2022-10-17           DKK           117            DKK383,759
#> 97  2022-10-17           DKK           117            DKK383,759
#> 98  2022-10-17           DKK           117            DKK383,759
#> 99  2022-10-17           DKK           117            DKK383,759
#> 100 2022-10-17           DKK           117            DKK383,759
#> 101 2022-10-17           DKK           117            DKK383,759
#> 102 2022-10-17           DKK           117            DKK383,759
#> 103 2022-10-17           DKK           117            DKK383,759
#> 104 2022-10-17           DKK           117            DKK383,759
#> 105 2022-10-17           DKK           117            DKK383,759
#> 106 2022-10-17           DKK           117            DKK383,759
#> 107 2022-10-17           DKK           117            DKK383,759
#> 108 2022-10-17           DKK           117            DKK383,759
#> 109 2022-10-17           DKK           117            DKK383,759
#> 110 2022-10-17           DKK           117            DKK383,759
#> 111 2022-10-17           DKK           117            DKK383,759
#> 112 2022-10-17           DKK           117            DKK383,759
#> 113 2022-10-17           DKK           117            DKK383,759
#> 114 2022-10-17           DKK           117            DKK383,759
#> 115 2022-10-17           DKK           117            DKK383,759
#> 116 2022-10-17           DKK           117            DKK383,759
#> 117 2022-10-17           DKK           117            DKK383,759
#> 118 2022-10-17           DKK           117            DKK383,759
#> 119 2022-10-17           DKK           117            DKK383,759
#> 120 2022-10-17           DKK           117            DKK383,759
#> 121 2022-10-17           DKK           117            DKK383,759
#> 122 2022-10-17           DKK           117            DKK383,759
#> 123 2022-10-17           DKK           117            DKK383,759
#> 124 2022-10-17           DKK           117            DKK383,759
#> 125 2022-10-17           DKK           117            DKK383,759
#> 126 2022-10-17           DKK           117            DKK383,759
#> 127 2022-10-17           DKK           117            DKK383,759
#> 128 2022-10-17           DKK           117            DKK383,759
#> 129 2022-10-17           DKK           117            DKK383,759
#> 130 2022-10-17           DKK           117            DKK383,759
#> 131 2022-10-17           DKK           117            DKK383,759
#> 132 2022-10-17           DKK           117            DKK383,759
#> 133 2022-10-17           DKK           117            DKK383,759
#> 134 2022-10-17           DKK           117            DKK383,759
#> 135 2022-10-17           DKK           117            DKK383,759
#> 136 2022-10-17           DKK           117            DKK383,759
#> 137 2022-10-17           DKK           117            DKK383,759
#> 138 2022-10-17           DKK           117            DKK383,759
#> 139 2022-10-17           DKK           117            DKK383,759
#> 140 2022-10-17           DKK           117            DKK383,759
#> 141 2022-10-17           DKK           117            DKK383,759
#> 142 2022-10-17           DKK           117            DKK383,759
#> 143 2022-10-17           DKK           117            DKK383,759
#> 144 2022-10-17           DKK           117            DKK383,759
#> 145 2022-10-17           DKK           117            DKK383,759
#> 146 2022-10-17           DKK           117            DKK383,759
#> 147 2022-10-17           DKK           117            DKK383,759
#> 148 2022-10-17           DKK           117            DKK383,759
#> 149 2022-10-17           DKK           117            DKK383,759
#> 150 2022-10-17           DKK           117            DKK383,759
#> 151 2022-10-17           DKK           117            DKK383,759
#> 152 2022-10-17           DKK           117            DKK383,759
#> 153 2022-10-17           DKK           117            DKK383,759
#> 154 2022-10-17           DKK           117            DKK383,759
#> 155 2022-10-17           DKK           117            DKK383,759
#> 156 2022-10-17           DKK           117            DKK383,759
#> 157 2022-10-17           DKK           117            DKK383,759
#> 158 2022-10-17           DKK           117            DKK383,759
#> 159 2022-10-17           DKK           117            DKK383,759
#> 160 2022-10-17           DKK           117            DKK383,759
#> 161 2022-10-17           DKK           117            DKK383,759
#> 162 2022-10-17           DKK           117            DKK383,759
#> 163 2022-10-17           DKK           117            DKK383,759
#> 164 2022-10-17           DKK           117            DKK383,759
#> 165 2022-10-17           DKK           117            DKK383,759
#> 166 2022-10-17           DKK           117            DKK383,759
#> 167 2022-10-17           DKK           117            DKK383,759
#> 168 2022-10-17           DKK           117            DKK383,759
#> 169 2022-10-17           DKK           117            DKK383,759
#> 170 2022-10-17           DKK           117            DKK383,759
#> 171 2022-10-17           DKK           117            DKK383,759
#> 172 2022-10-17           DKK           117            DKK383,759
#> 173 2022-10-17           DKK           117            DKK383,759
#> 174 2022-10-17           DKK           117            DKK383,759
#> 175 2022-10-17           DKK           117            DKK383,759
#> 176 2022-10-17           DKK           117            DKK383,759
#> 177 2022-10-17           DKK           117            DKK383,759
#> 178 2022-10-17           DKK           117            DKK383,759
#> 179 2022-10-17           DKK           117            DKK383,759
#> 180 2022-10-17           DKK           117            DKK383,759
#> 181 2022-10-17           DKK           117            DKK383,759
#> 182 2022-10-17           DKK           117            DKK383,759
#> 183 2022-10-17           DKK           117            DKK383,759
#> 184 2022-10-17           DKK           117            DKK383,759
#> 185 2022-10-17           DKK           117            DKK383,759
#> 186 2022-10-17           DKK           117            DKK383,759
#> 187 2022-10-17           DKK           117            DKK383,759
#> 188 2022-10-17           DKK           117            DKK383,759
#> 189 2022-10-17           DKK           117            DKK383,759
#> 190 2022-10-17           DKK           117            DKK383,759
#> 191 2022-10-17           DKK           117            DKK383,759
#> 192 2022-10-17           DKK           117            DKK383,759
#> 193 2022-10-17           DKK           117            DKK383,759
#> 194 2022-10-17           DKK           117            DKK383,759
#> 195 2022-10-17           DKK           117            DKK383,759
#> 196 2022-10-17           DKK           117            DKK383,759
#> 197 2022-10-17           DKK           117            DKK383,759
#> 198 2022-10-17           DKK           117            DKK383,759
#> 199 2022-10-17           DKK           117            DKK383,759
#> 200 2022-10-17           DKK           117            DKK383,759
#> 201 2022-10-17           DKK           117            DKK383,759
#> 202 2022-10-17           DKK           117            DKK383,759
#> 203 2022-10-17           DKK           117            DKK383,759
#> 204 2022-10-17           DKK           117            DKK383,759
#> 205 2022-10-17           DKK           117            DKK383,759
#> 206 2022-10-17           DKK           117            DKK383,759
#> 207 2022-10-17           DKK           117            DKK383,759
#> 208 2022-10-17           DKK           117            DKK383,759
#> 209 2022-10-17           DKK           117            DKK383,759
#> 210 2022-10-17           DKK           117            DKK383,759
#> 211 2022-10-17           DKK           117            DKK383,759
#> 212 2022-10-17           DKK           117            DKK383,759
#> 213 2022-10-17           DKK           117            DKK383,759
#> 214 2022-10-17           DKK           117            DKK383,759
#> 215 2022-10-17           DKK           117            DKK383,759
#> 216 2022-10-17           DKK           117            DKK383,759
#> 217 2022-10-17           DKK           117            DKK383,759
#> 218 2022-10-17           DKK           117            DKK383,759
#> 219 2022-10-17           DKK           117            DKK383,759
#> 220 2022-10-17           DKK           117            DKK383,759
#> 221 2022-10-17           DKK           117            DKK383,759
#>     is_30_day_available is_90_day_available internal_id
#> 1                  TRUE                TRUE 41459763029
#> 2                  TRUE                TRUE 41459763029
#> 3                  TRUE                TRUE 41459763029
#> 4                  TRUE                TRUE 41459763029
#> 5                  TRUE                TRUE 41459763029
#> 6                  TRUE                TRUE 41459763029
#> 7                  TRUE                TRUE 41459763029
#> 8                  TRUE                TRUE 41459763029
#> 9                  TRUE                TRUE 41459763029
#> 10                 TRUE                TRUE 41459763029
#> 11                 TRUE                TRUE 41459763029
#> 12                 TRUE                TRUE 41459763029
#> 13                 TRUE                TRUE 41459763029
#> 14                 TRUE                TRUE 41459763029
#> 15                 TRUE                TRUE 41459763029
#> 16                 TRUE                TRUE 41459763029
#> 17                 TRUE                TRUE 41459763029
#> 18                 TRUE                TRUE 41459763029
#> 19                 TRUE                TRUE 41459763029
#> 20                 TRUE                TRUE 41459763029
#> 21                 TRUE                TRUE 41459763029
#> 22                 TRUE                TRUE 41459763029
#> 23                 TRUE                TRUE 41459763029
#> 24                 TRUE                TRUE 41459763029
#> 25                 TRUE                TRUE 41459763029
#> 26                 TRUE                TRUE 41459763029
#> 27                 TRUE                TRUE 41459763029
#> 28                 TRUE                TRUE 41459763029
#> 29                 TRUE                TRUE 41459763029
#> 30                 TRUE                TRUE 41459763029
#> 31                 TRUE                TRUE 41459763029
#> 32                 TRUE                TRUE 41459763029
#> 33                 TRUE                TRUE 41459763029
#> 34                 TRUE                TRUE 41459763029
#> 35                 TRUE                TRUE 41459763029
#> 36                 TRUE                TRUE 41459763029
#> 37                 TRUE                TRUE 41459763029
#> 38                 TRUE                TRUE 41459763029
#> 39                 TRUE                TRUE 41459763029
#> 40                 TRUE                TRUE 41459763029
#> 41                 TRUE                TRUE 41459763029
#> 42                 TRUE                TRUE 41459763029
#> 43                 TRUE                TRUE 41459763029
#> 44                 TRUE                TRUE 41459763029
#> 45                 TRUE                TRUE 41459763029
#> 46                 TRUE                TRUE 41459763029
#> 47                 TRUE                TRUE 41459763029
#> 48                 TRUE                TRUE 41459763029
#> 49                 TRUE                TRUE 41459763029
#> 50                 TRUE                TRUE 41459763029
#> 51                 TRUE                TRUE 41459763029
#> 52                 TRUE                TRUE 41459763029
#> 53                 TRUE                TRUE 41459763029
#> 54                 TRUE                TRUE 41459763029
#> 55                 TRUE                TRUE 41459763029
#> 56                 TRUE                TRUE 41459763029
#> 57                 TRUE                TRUE 41459763029
#> 58                 TRUE                TRUE 41459763029
#> 59                 TRUE                TRUE 41459763029
#> 60                 TRUE                TRUE 41459763029
#> 61                 TRUE                TRUE 41459763029
#> 62                 TRUE                TRUE 41459763029
#> 63                 TRUE                TRUE 41459763029
#> 64                 TRUE                TRUE 41459763029
#> 65                 TRUE                TRUE 41459763029
#> 66                 TRUE                TRUE 41459763029
#> 67                 TRUE                TRUE 41459763029
#> 68                 TRUE                TRUE 41459763029
#> 69                 TRUE                TRUE 41459763029
#> 70                 TRUE                TRUE 41459763029
#> 71                 TRUE                TRUE 41459763029
#> 72                 TRUE                TRUE 41459763029
#> 73                 TRUE                TRUE 41459763029
#> 74                 TRUE                TRUE 41459763029
#> 75                 TRUE                TRUE 41459763029
#> 76                 TRUE                TRUE 41459763029
#> 77                 TRUE                TRUE 41459763029
#> 78                 TRUE                TRUE 41459763029
#> 79                 TRUE                TRUE 41459763029
#> 80                 TRUE                TRUE 41459763029
#> 81                 TRUE                TRUE 41459763029
#> 82                 TRUE                TRUE 41459763029
#> 83                 TRUE                TRUE 41459763029
#> 84                 TRUE                TRUE 41459763029
#> 85                 TRUE                TRUE 41459763029
#> 86                 TRUE                TRUE 41459763029
#> 87                 TRUE                TRUE 41459763029
#> 88                 TRUE                TRUE 41459763029
#> 89                 TRUE                TRUE 41459763029
#> 90                 TRUE                TRUE 41459763029
#> 91                 TRUE                TRUE 41459763029
#> 92                 TRUE                TRUE 41459763029
#> 93                 TRUE                TRUE 41459763029
#> 94                 TRUE                TRUE 41459763029
#> 95                 TRUE                TRUE 41459763029
#> 96                 TRUE                TRUE 41459763029
#> 97                 TRUE                TRUE 41459763029
#> 98                 TRUE                TRUE 41459763029
#> 99                 TRUE                TRUE 41459763029
#> 100                TRUE                TRUE 41459763029
#> 101                TRUE                TRUE 41459763029
#> 102                TRUE                TRUE 41459763029
#> 103                TRUE                TRUE 41459763029
#> 104                TRUE                TRUE 41459763029
#> 105                TRUE                TRUE 41459763029
#> 106                TRUE                TRUE 41459763029
#> 107                TRUE                TRUE 41459763029
#> 108                TRUE                TRUE 41459763029
#> 109                TRUE                TRUE 41459763029
#> 110                TRUE                TRUE 41459763029
#> 111                TRUE                TRUE 41459763029
#> 112                TRUE                TRUE 41459763029
#> 113                TRUE                TRUE 41459763029
#> 114                TRUE                TRUE 41459763029
#> 115                TRUE                TRUE 41459763029
#> 116                TRUE                TRUE 41459763029
#> 117                TRUE                TRUE 41459763029
#> 118                TRUE                TRUE 41459763029
#> 119                TRUE                TRUE 41459763029
#> 120                TRUE                TRUE 41459763029
#> 121                TRUE                TRUE 41459763029
#> 122                TRUE                TRUE 41459763029
#> 123                TRUE                TRUE 41459763029
#> 124                TRUE                TRUE 41459763029
#> 125                TRUE                TRUE 41459763029
#> 126                TRUE                TRUE 41459763029
#> 127                TRUE                TRUE 41459763029
#> 128                TRUE                TRUE 41459763029
#> 129                TRUE                TRUE 41459763029
#> 130                TRUE                TRUE 41459763029
#> 131                TRUE                TRUE 41459763029
#> 132                TRUE                TRUE 41459763029
#> 133                TRUE                TRUE 41459763029
#> 134                TRUE                TRUE 41459763029
#> 135                TRUE                TRUE 41459763029
#> 136                TRUE                TRUE 41459763029
#> 137                TRUE                TRUE 41459763029
#> 138                TRUE                TRUE 41459763029
#> 139                TRUE                TRUE 41459763029
#> 140                TRUE                TRUE 41459763029
#> 141                TRUE                TRUE 41459763029
#> 142                TRUE                TRUE 41459763029
#> 143                TRUE                TRUE 41459763029
#> 144                TRUE                TRUE 41459763029
#> 145                TRUE                TRUE 41459763029
#> 146                TRUE                TRUE 41459763029
#> 147                TRUE                TRUE 41459763029
#> 148                TRUE                TRUE 41459763029
#> 149                TRUE                TRUE 41459763029
#> 150                TRUE                TRUE 41459763029
#> 151                TRUE                TRUE 41459763029
#> 152                TRUE                TRUE 41459763029
#> 153                TRUE                TRUE 41459763029
#> 154                TRUE                TRUE 41459763029
#> 155                TRUE                TRUE 41459763029
#> 156                TRUE                TRUE 41459763029
#> 157                TRUE                TRUE 41459763029
#> 158                TRUE                TRUE 41459763029
#> 159                TRUE                TRUE 41459763029
#> 160                TRUE                TRUE 41459763029
#> 161                TRUE                TRUE 41459763029
#> 162                TRUE                TRUE 41459763029
#> 163                TRUE                TRUE 41459763029
#> 164                TRUE                TRUE 41459763029
#> 165                TRUE                TRUE 41459763029
#> 166                TRUE                TRUE 41459763029
#> 167                TRUE                TRUE 41459763029
#> 168                TRUE                TRUE 41459763029
#> 169                TRUE                TRUE 41459763029
#> 170                TRUE                TRUE 41459763029
#> 171                TRUE                TRUE 41459763029
#> 172                TRUE                TRUE 41459763029
#> 173                TRUE                TRUE 41459763029
#> 174                TRUE                TRUE 41459763029
#> 175                TRUE                TRUE 41459763029
#> 176                TRUE                TRUE 41459763029
#> 177                TRUE                TRUE 41459763029
#> 178                TRUE                TRUE 41459763029
#> 179                TRUE                TRUE 41459763029
#> 180                TRUE                TRUE 41459763029
#> 181                TRUE                TRUE 41459763029
#> 182                TRUE                TRUE 41459763029
#> 183                TRUE                TRUE 41459763029
#> 184                TRUE                TRUE 41459763029
#> 185                TRUE                TRUE 41459763029
#> 186                TRUE                TRUE 41459763029
#> 187                TRUE                TRUE 41459763029
#> 188                TRUE                TRUE 41459763029
#> 189                TRUE                TRUE 41459763029
#> 190                TRUE                TRUE 41459763029
#> 191                TRUE                TRUE 41459763029
#> 192                TRUE                TRUE 41459763029
#> 193                TRUE                TRUE 41459763029
#> 194                TRUE                TRUE 41459763029
#> 195                TRUE                TRUE 41459763029
#> 196                TRUE                TRUE 41459763029
#> 197                TRUE                TRUE 41459763029
#> 198                TRUE                TRUE 41459763029
#> 199                TRUE                TRUE 41459763029
#> 200                TRUE                TRUE 41459763029
#> 201                TRUE                TRUE 41459763029
#> 202                TRUE                TRUE 41459763029
#> 203                TRUE                TRUE 41459763029
#> 204                TRUE                TRUE 41459763029
#> 205                TRUE                TRUE 41459763029
#> 206                TRUE                TRUE 41459763029
#> 207                TRUE                TRUE 41459763029
#> 208                TRUE                TRUE 41459763029
#> 209                TRUE                TRUE 41459763029
#> 210                TRUE                TRUE 41459763029
#> 211                TRUE                TRUE 41459763029
#> 212                TRUE                TRUE 41459763029
#> 213                TRUE                TRUE 41459763029
#> 214                TRUE                TRUE 41459763029
#> 215                TRUE                TRUE 41459763029
#> 216                TRUE                TRUE 41459763029
#> 217                TRUE                TRUE 41459763029
#> 218                TRUE                TRUE 41459763029
#> 219                TRUE                TRUE 41459763029
#> 220                TRUE                TRUE 41459763029
#> 221                TRUE                TRUE 41459763029
```

## Get Targeting criteria (Last 7 Days)

The following code retrieves the targeting criteria used by the Social
Democrats in Denmark in the last 7 days. Just put in the right Page ID.

``` r
get_targeting("41459763029", timeframe = "LAST_7_DAYS")
#> Warning: Outer names are only allowed for unnamed scalar atomic inputs
#>                                    value num_ads total_spend_pct
#> 1                                    All      77    1.0000000000
#> 2                                  Women       0    0.0000000000
#> 3                                    Men       0    0.0000000000
#> 4                          5884, Denmark       1    0.0170573489
#> 5                          5882, Denmark       1    0.0170573489
#> 6                          8620, Denmark       1    0.0144934990
#> 7                          6280, Denmark       2    0.0264223990
#> 8                          6372, Denmark       2    0.0264223990
#> 9                          6270, Denmark       2    0.0264223990
#> 10                         6240, Denmark       2    0.0264223990
#> 11                         8881, Denmark       1    0.0144934990
#> 12                        Ishøj, Denmark       1    0.0199719564
#> 13                     Ballerup, Denmark       1    0.0199719564
#> 14                     Helsinge, Denmark       1    0.0007312233
#> 15          Herlev Municipality, Denmark       1    0.0199719564
#> 16                      Aalborg, Denmark       1    0.0081162036
#> 17                         3370, Denmark       1    0.0118844125
#> 18                         6780, Denmark       2    0.0264223990
#> 19                         5881, Denmark       1    0.0170573489
#> 20                         8883, Denmark       1    0.0144934990
#> 21                         6792, Denmark       2    0.0264223990
#> 22                         5772, Denmark       1    0.0170573489
#> 23                               Denmark      61    0.8154600717
#> 24                         8670, Denmark       1    0.0144934990
#> 25                         8653, Denmark       1    0.0144934990
#> 26                       Tårnby, Denmark       1    0.0099859782
#> 27                       Aarhus, Denmark       1    0.0024657877
#> 28     Albertslund Municipality, Denmark       1    0.0199719564
#> 29                         3390, Denmark       1    0.0118844125
#> 30                         3220, Denmark       1    0.0118844125
#> 31                       Aarhus, Denmark       2    0.0129435753
#> 32               Zealand Region, Denmark       1    0.0005516754
#> 33                         6360, Denmark       2    0.0264223990
#> 34                         5762, Denmark       1    0.0170573489
#> 35                         6261, Denmark       2    0.0264223990
#> 36                         5771, Denmark       1    0.0170573489
#> 37                         5892, Denmark       1    0.0170573489
#> 38                         5700, Denmark       1    0.0170573489
#> 39                         5883, Denmark       1    0.0170573489
#> 40                         5874, Denmark       1    0.0170573489
#> 41                         8654, Denmark       1    0.0144934990
#> 42                         8600, Denmark       1    0.0144934990
#> 43                         8641, Denmark       1    0.0144934990
#> 44                         3320, Denmark       1    0.0118844125
#> 45                         8840, Denmark       1    0.0144934990
#> 46                         8632, Denmark       1    0.0144934990
#> 47                         8882, Denmark       1    0.0144934990
#> 48                         8680, Denmark       1    0.0144934990
#> 49                         3360, Denmark       1    0.0118844125
#> 50                         3300, Denmark       1    0.0118844125
#> 51                         8643, Denmark       1    0.0144934990
#> 52                         3310, Denmark       1    0.0118844125
#> 53                                    13       0    0.0000000000
#> 54                                    14       0    0.0000000000
#> 55                                    15       0    0.0000000000
#> 56                                    16       0    0.0000000000
#> 57                                    17       0    0.0000000000
#> 58                                    18      60    0.6680257417
#> 59                                    19      60    0.6680257417
#> 60                                    20      60    0.6680257417
#> 61                                    21      60    0.6680257417
#> 62                                    22      60    0.6680257417
#> 63                                    23      60    0.6680257417
#> 64                                    24      60    0.6680257417
#> 65                                    25      60    0.6680257417
#> 66                                    26      60    0.6680257417
#> 67                                    27      60    0.6680257417
#> 68                                    28      60    0.6680257417
#> 69                                    29      60    0.6680257417
#> 70                                    30      60    0.6680257417
#> 71                                    31      60    0.6680257417
#> 72                                    32      60    0.6680257417
#> 73                                    33      60    0.6680257417
#> 74                                    34      60    0.6680257417
#> 75                                    35      60    0.6680257417
#> 76                                    36      60    0.6680257417
#> 77                                    37      60    0.6680257417
#> 78                                    38      60    0.6680257417
#> 79                                    39      60    0.6680257417
#> 80                                    40      68    0.8251960010
#> 81                                    41      39    0.5711277010
#> 82                                    42      39    0.5711277010
#> 83                                    43      39    0.5711277010
#> 84                                    44      39    0.5711277010
#> 85                                    45      39    0.5711277010
#> 86                                    46      39    0.5711277010
#> 87                                    47      39    0.5711277010
#> 88                                    48      39    0.5711277010
#> 89                                    49      39    0.5711277010
#> 90                                    50      42    0.6218690026
#> 91                                    51      42    0.6218690026
#> 92                                    52      42    0.6218690026
#> 93                                    53      42    0.6218690026
#> 94                                    54      42    0.6218690026
#> 95                                    55      42    0.6218690026
#> 96                                    56      48    0.7459317000
#> 97                                    57      48    0.7459317000
#> 98                                    58      48    0.7459317000
#> 99                                    59      48    0.7459317000
#> 100                                   60      48    0.7459317000
#> 101                                   61      48    0.7459317000
#> 102                                   62      48    0.7459317000
#> 103                                   63      48    0.7459317000
#> 104                                   64      48    0.7459317000
#> 105                                  65+      34    0.4956082916
#> 106                   Lookalike audience       7    0.0224585648
#> 107                   Lookalike audience       0    0.0000000000
#> 108                              Camping      34    0.3390058350
#> 109                               School      29    0.2540683000
#> 110                                DR P1      35    0.3472214490
#> 111                            Isabellas      35    0.3472214490
#> 112                         Kindergarten      29    0.2540683000
#> 113                               Børsen      17    0.3010647100
#> 114                                House       8    0.1571702594
#> 115                     Danish Superliga       3    0.0507413016
#> 116                                Bilka       5    0.0849375350
#> 117                  Animal rescue group       3    0.0507413016
#> 118          Single-family detached home      29    0.2540683000
#> 119                       Apprenticeship      29    0.2540683000
#> 120 The Fast and the Furious (2001 film)       6    0.0931531490
#> 121                              Finance      51    0.6400705449
#> 122                   Silvan Byggemarked       8    0.1571702594
#> 123          Single-family detached home       8    0.1571702594
#> 124                              Pension       6    0.1240626974
#> 125                  Animal rescue group      14    0.2812329567
#> 126                      Kevin Magnussen       9    0.1748039990
#> 127                              Camping       9    0.1748039990
#> 128       Louisiana Museum of Modern Art       5    0.0849375350
#> 129       Louisiana Museum of Modern Art      29    0.2540683000
#> 130                                Bilka       8    0.1571702594
#> 131                 Vocational education      29    0.2540683000
#> 132                             Pedagogy       6    0.0931531490
#> 133                                  DR2      35    0.3472214490
#> 134                               Lurpak       6    0.0931531490
#> 135                             Circle K      11    0.1780906840
#> 136                       Premier League       6    0.0931531490
#> 137                      Kevin Magnussen      11    0.1780906840
#> 138                             Veganism      22    0.4169117933
#> 139                                DR P3      29    0.2540683000
#> 140                      Familie Journal       6    0.0931531490
#> 141                         weber grills       5    0.0849375350
#> 142                                  DR2       5    0.0849375350
#> 143                           Greenhouse       9    0.1748039990
#> 144                   Matas (drug store)       6    0.0931531490
#> 145                              FlixBus       6    0.1240626974
#> 146                              Cruises       5    0.0849375350
#> 147                                Zizzi       6    0.0931531490
#> 148                           Motherhood       6    0.0931531490
#> 149                            Gardening       8    0.1571702594
#> 150                         Eurowoman DK       9    0.1748039990
#> 151                          Health care      12    0.2172158464
#> 152                         Eurowoman DK      29    0.2540683000
#> 153                              FlixBus       8    0.1571702594
#> 154                      ALT for damerne       9    0.1748039990
#> 155                       Premier League       6    0.1240626974
#> 156                                  RVs       5    0.0849375350
#> 157                            Saxo Bank       5    0.0849375350
#> 158                              Ecology       3    0.0507413016
#> 159                       Mortgage loans      46    0.5562216813
#> 160                           Greenhouse       8    0.1571702594
#> 161                        Skateboarding       6    0.0931531490
#> 162                                  BMW       6    0.0931531490
#> 163                                  Bus       3    0.0507413016
#> 164                                  DR3      14    0.2812329567
#> 165               Dancing with the Stars       5    0.0849375350
#> 166                              Climate       5    0.0849375350
#> 167                   Investment banking       6    0.0931531490
#> 168                  Natural environment       5    0.0849375350
#> 169                              Ecology       5    0.0849375350
#> 170                            Eurosport       6    0.0931531490
#> 171                                 Lidl       5    0.0849375350
#> 172                         weber grills       6    0.1240626974
#> 173                         Grøn Koncert       6    0.0931531490
#> 174                                DR P1       5    0.0849375350
#> 175                      Filling station       5    0.0849375350
#> 176                            Preschool       4    0.0716581312
#> 177                          Video games       6    0.0931531490
#> 178                      Filling station       3    0.0507413016
#> 179                                 JYSK       3    0.0507413016
#> 180                             Circle K       3    0.0507413016
#> 181                                Skole       4    0.0716581312
#> 182               Dancing with the Stars       3    0.0507413016
#> 183                            Isabellas       3    0.0507413016
#>                   type location_type num_obfuscated is_exclusion detailed_type
#> 1               gender          <NA>             NA           NA          <NA>
#> 2               gender          <NA>             NA           NA          <NA>
#> 3               gender          <NA>             NA           NA          <NA>
#> 4             location          zips              0        FALSE          <NA>
#> 5             location          zips              0        FALSE          <NA>
#> 6             location          zips              0        FALSE          <NA>
#> 7             location          zips              0        FALSE          <NA>
#> 8             location          zips              0        FALSE          <NA>
#> 9             location          zips              0        FALSE          <NA>
#> 10            location          zips              0        FALSE          <NA>
#> 11            location          zips              0        FALSE          <NA>
#> 12            location          TOWN              1        FALSE          <NA>
#> 13            location          TOWN              1        FALSE          <NA>
#> 14            location          CITY              1        FALSE          <NA>
#> 15            location          CITY              1        FALSE          <NA>
#> 16            location          CITY              1        FALSE          <NA>
#> 17            location          zips              0        FALSE          <NA>
#> 18            location          zips              0        FALSE          <NA>
#> 19            location          zips              0        FALSE          <NA>
#> 20            location          zips              0        FALSE          <NA>
#> 21            location          zips              0        FALSE          <NA>
#> 22            location          zips              0        FALSE          <NA>
#> 23            location     countries              0        FALSE          <NA>
#> 24            location          zips              0        FALSE          <NA>
#> 25            location          zips              0        FALSE          <NA>
#> 26            location          TOWN              1        FALSE          <NA>
#> 27            location          CITY              1        FALSE          <NA>
#> 28            location          TOWN              1        FALSE          <NA>
#> 29            location          zips              0        FALSE          <NA>
#> 30            location          zips              0        FALSE          <NA>
#> 31            location          CITY              0        FALSE          <NA>
#> 32            location       regions              0        FALSE          <NA>
#> 33            location          zips              0        FALSE          <NA>
#> 34            location          zips              0        FALSE          <NA>
#> 35            location          zips              0        FALSE          <NA>
#> 36            location          zips              0        FALSE          <NA>
#> 37            location          zips              0        FALSE          <NA>
#> 38            location          zips              0        FALSE          <NA>
#> 39            location          zips              0        FALSE          <NA>
#> 40            location          zips              0        FALSE          <NA>
#> 41            location          zips              0        FALSE          <NA>
#> 42            location          zips              0        FALSE          <NA>
#> 43            location          zips              0        FALSE          <NA>
#> 44            location          zips              0        FALSE          <NA>
#> 45            location          zips              0        FALSE          <NA>
#> 46            location          zips              0        FALSE          <NA>
#> 47            location          zips              0        FALSE          <NA>
#> 48            location          zips              0        FALSE          <NA>
#> 49            location          zips              0        FALSE          <NA>
#> 50            location          zips              0        FALSE          <NA>
#> 51            location          zips              0        FALSE          <NA>
#> 52            location          zips              0        FALSE          <NA>
#> 53                 age          <NA>             NA           NA          <NA>
#> 54                 age          <NA>             NA           NA          <NA>
#> 55                 age          <NA>             NA           NA          <NA>
#> 56                 age          <NA>             NA           NA          <NA>
#> 57                 age          <NA>             NA           NA          <NA>
#> 58                 age          <NA>             NA           NA          <NA>
#> 59                 age          <NA>             NA           NA          <NA>
#> 60                 age          <NA>             NA           NA          <NA>
#> 61                 age          <NA>             NA           NA          <NA>
#> 62                 age          <NA>             NA           NA          <NA>
#> 63                 age          <NA>             NA           NA          <NA>
#> 64                 age          <NA>             NA           NA          <NA>
#> 65                 age          <NA>             NA           NA          <NA>
#> 66                 age          <NA>             NA           NA          <NA>
#> 67                 age          <NA>             NA           NA          <NA>
#> 68                 age          <NA>             NA           NA          <NA>
#> 69                 age          <NA>             NA           NA          <NA>
#> 70                 age          <NA>             NA           NA          <NA>
#> 71                 age          <NA>             NA           NA          <NA>
#> 72                 age          <NA>             NA           NA          <NA>
#> 73                 age          <NA>             NA           NA          <NA>
#> 74                 age          <NA>             NA           NA          <NA>
#> 75                 age          <NA>             NA           NA          <NA>
#> 76                 age          <NA>             NA           NA          <NA>
#> 77                 age          <NA>             NA           NA          <NA>
#> 78                 age          <NA>             NA           NA          <NA>
#> 79                 age          <NA>             NA           NA          <NA>
#> 80                 age          <NA>             NA           NA          <NA>
#> 81                 age          <NA>             NA           NA          <NA>
#> 82                 age          <NA>             NA           NA          <NA>
#> 83                 age          <NA>             NA           NA          <NA>
#> 84                 age          <NA>             NA           NA          <NA>
#> 85                 age          <NA>             NA           NA          <NA>
#> 86                 age          <NA>             NA           NA          <NA>
#> 87                 age          <NA>             NA           NA          <NA>
#> 88                 age          <NA>             NA           NA          <NA>
#> 89                 age          <NA>             NA           NA          <NA>
#> 90                 age          <NA>             NA           NA          <NA>
#> 91                 age          <NA>             NA           NA          <NA>
#> 92                 age          <NA>             NA           NA          <NA>
#> 93                 age          <NA>             NA           NA          <NA>
#> 94                 age          <NA>             NA           NA          <NA>
#> 95                 age          <NA>             NA           NA          <NA>
#> 96                 age          <NA>             NA           NA          <NA>
#> 97                 age          <NA>             NA           NA          <NA>
#> 98                 age          <NA>             NA           NA          <NA>
#> 99                 age          <NA>             NA           NA          <NA>
#> 100                age          <NA>             NA           NA          <NA>
#> 101                age          <NA>             NA           NA          <NA>
#> 102                age          <NA>             NA           NA          <NA>
#> 103                age          <NA>             NA           NA          <NA>
#> 104                age          <NA>             NA           NA          <NA>
#> 105                age          <NA>             NA           NA          <NA>
#> 106 lookalike_audience          <NA>             NA        FALSE          <NA>
#> 107 lookalike_audience          <NA>             NA         TRUE          <NA>
#> 108           detailed          <NA>             NA         TRUE     INTERESTS
#> 109           detailed          <NA>             NA        FALSE     INTERESTS
#> 110           detailed          <NA>             NA         TRUE     INTERESTS
#> 111           detailed          <NA>             NA        FALSE     INTERESTS
#> 112           detailed          <NA>             NA        FALSE     INTERESTS
#> 113           detailed          <NA>             NA         TRUE     INTERESTS
#> 114           detailed          <NA>             NA        FALSE     INTERESTS
#> 115           detailed          <NA>             NA        FALSE     INTERESTS
#> 116           detailed          <NA>             NA         TRUE     INTERESTS
#> 117           detailed          <NA>             NA        FALSE     INTERESTS
#> 118           detailed          <NA>             NA         TRUE     INTERESTS
#> 119           detailed          <NA>             NA        FALSE     INTERESTS
#> 120           detailed          <NA>             NA         TRUE     INTERESTS
#> 121           detailed          <NA>             NA         TRUE     INTERESTS
#> 122           detailed          <NA>             NA        FALSE     INTERESTS
#> 123           detailed          <NA>             NA        FALSE     INTERESTS
#> 124           detailed          <NA>             NA        FALSE     INTERESTS
#> 125           detailed          <NA>             NA         TRUE     INTERESTS
#> 126           detailed          <NA>             NA        FALSE     INTERESTS
#> 127           detailed          <NA>             NA        FALSE     INTERESTS
#> 128           detailed          <NA>             NA        FALSE     INTERESTS
#> 129           detailed          <NA>             NA         TRUE     INTERESTS
#> 130           detailed          <NA>             NA        FALSE     INTERESTS
#> 131           detailed          <NA>             NA        FALSE     INTERESTS
#> 132           detailed          <NA>             NA        FALSE     INTERESTS
#> 133           detailed          <NA>             NA         TRUE     INTERESTS
#> 134           detailed          <NA>             NA        FALSE     INTERESTS
#> 135           detailed          <NA>             NA         TRUE     INTERESTS
#> 136           detailed          <NA>             NA         TRUE     INTERESTS
#> 137           detailed          <NA>             NA         TRUE     INTERESTS
#> 138           detailed          <NA>             NA         TRUE     INTERESTS
#> 139           detailed          <NA>             NA        FALSE     INTERESTS
#> 140           detailed          <NA>             NA        FALSE     INTERESTS
#> 141           detailed          <NA>             NA         TRUE     INTERESTS
#> 142           detailed          <NA>             NA        FALSE     INTERESTS
#> 143           detailed          <NA>             NA         TRUE     INTERESTS
#> 144           detailed          <NA>             NA        FALSE     INTERESTS
#> 145           detailed          <NA>             NA        FALSE     INTERESTS
#> 146           detailed          <NA>             NA         TRUE     INTERESTS
#> 147           detailed          <NA>             NA        FALSE     INTERESTS
#> 148           detailed          <NA>             NA        FALSE     INTERESTS
#> 149           detailed          <NA>             NA        FALSE     INTERESTS
#> 150           detailed          <NA>             NA         TRUE     INTERESTS
#> 151           detailed          <NA>             NA        FALSE     INTERESTS
#> 152           detailed          <NA>             NA        FALSE     INTERESTS
#> 153           detailed          <NA>             NA         TRUE     INTERESTS
#> 154           detailed          <NA>             NA         TRUE     INTERESTS
#> 155           detailed          <NA>             NA        FALSE     INTERESTS
#> 156           detailed          <NA>             NA         TRUE     INTERESTS
#> 157           detailed          <NA>             NA         TRUE     INTERESTS
#> 158           detailed          <NA>             NA         TRUE     INTERESTS
#> 159           detailed          <NA>             NA         TRUE     INTERESTS
#> 160           detailed          <NA>             NA        FALSE     INTERESTS
#> 161           detailed          <NA>             NA         TRUE     INTERESTS
#> 162           detailed          <NA>             NA         TRUE     INTERESTS
#> 163           detailed          <NA>             NA        FALSE     INTERESTS
#> 164           detailed          <NA>             NA         TRUE     INTERESTS
#> 165           detailed          <NA>             NA         TRUE     INTERESTS
#> 166           detailed          <NA>             NA        FALSE     INTERESTS
#> 167           detailed          <NA>             NA         TRUE     INTERESTS
#> 168           detailed          <NA>             NA        FALSE     INTERESTS
#> 169           detailed          <NA>             NA        FALSE     INTERESTS
#> 170           detailed          <NA>             NA         TRUE     INTERESTS
#> 171           detailed          <NA>             NA         TRUE     INTERESTS
#> 172           detailed          <NA>             NA        FALSE     INTERESTS
#> 173           detailed          <NA>             NA         TRUE     INTERESTS
#> 174           detailed          <NA>             NA        FALSE     INTERESTS
#> 175           detailed          <NA>             NA         TRUE     INTERESTS
#> 176           detailed          <NA>             NA        FALSE     INTERESTS
#> 177           detailed          <NA>             NA         TRUE     INTERESTS
#> 178           detailed          <NA>             NA        FALSE     INTERESTS
#> 179           detailed          <NA>             NA        FALSE     INTERESTS
#> 180           detailed          <NA>             NA        FALSE     INTERESTS
#> 181           detailed          <NA>             NA        FALSE     INTERESTS
#> 182           detailed          <NA>             NA        FALSE     INTERESTS
#> 183           detailed          <NA>             NA         TRUE     INTERESTS
#>             ds main_currency total_num_ads total_spend_formatted
#> 1   2022-10-17           DKK            77            DKK200,281
#> 2   2022-10-17           DKK            77            DKK200,281
#> 3   2022-10-17           DKK            77            DKK200,281
#> 4   2022-10-17           DKK            77            DKK200,281
#> 5   2022-10-17           DKK            77            DKK200,281
#> 6   2022-10-17           DKK            77            DKK200,281
#> 7   2022-10-17           DKK            77            DKK200,281
#> 8   2022-10-17           DKK            77            DKK200,281
#> 9   2022-10-17           DKK            77            DKK200,281
#> 10  2022-10-17           DKK            77            DKK200,281
#> 11  2022-10-17           DKK            77            DKK200,281
#> 12  2022-10-17           DKK            77            DKK200,281
#> 13  2022-10-17           DKK            77            DKK200,281
#> 14  2022-10-17           DKK            77            DKK200,281
#> 15  2022-10-17           DKK            77            DKK200,281
#> 16  2022-10-17           DKK            77            DKK200,281
#> 17  2022-10-17           DKK            77            DKK200,281
#> 18  2022-10-17           DKK            77            DKK200,281
#> 19  2022-10-17           DKK            77            DKK200,281
#> 20  2022-10-17           DKK            77            DKK200,281
#> 21  2022-10-17           DKK            77            DKK200,281
#> 22  2022-10-17           DKK            77            DKK200,281
#> 23  2022-10-17           DKK            77            DKK200,281
#> 24  2022-10-17           DKK            77            DKK200,281
#> 25  2022-10-17           DKK            77            DKK200,281
#> 26  2022-10-17           DKK            77            DKK200,281
#> 27  2022-10-17           DKK            77            DKK200,281
#> 28  2022-10-17           DKK            77            DKK200,281
#> 29  2022-10-17           DKK            77            DKK200,281
#> 30  2022-10-17           DKK            77            DKK200,281
#> 31  2022-10-17           DKK            77            DKK200,281
#> 32  2022-10-17           DKK            77            DKK200,281
#> 33  2022-10-17           DKK            77            DKK200,281
#> 34  2022-10-17           DKK            77            DKK200,281
#> 35  2022-10-17           DKK            77            DKK200,281
#> 36  2022-10-17           DKK            77            DKK200,281
#> 37  2022-10-17           DKK            77            DKK200,281
#> 38  2022-10-17           DKK            77            DKK200,281
#> 39  2022-10-17           DKK            77            DKK200,281
#> 40  2022-10-17           DKK            77            DKK200,281
#> 41  2022-10-17           DKK            77            DKK200,281
#> 42  2022-10-17           DKK            77            DKK200,281
#> 43  2022-10-17           DKK            77            DKK200,281
#> 44  2022-10-17           DKK            77            DKK200,281
#> 45  2022-10-17           DKK            77            DKK200,281
#> 46  2022-10-17           DKK            77            DKK200,281
#> 47  2022-10-17           DKK            77            DKK200,281
#> 48  2022-10-17           DKK            77            DKK200,281
#> 49  2022-10-17           DKK            77            DKK200,281
#> 50  2022-10-17           DKK            77            DKK200,281
#> 51  2022-10-17           DKK            77            DKK200,281
#> 52  2022-10-17           DKK            77            DKK200,281
#> 53  2022-10-17           DKK            77            DKK200,281
#> 54  2022-10-17           DKK            77            DKK200,281
#> 55  2022-10-17           DKK            77            DKK200,281
#> 56  2022-10-17           DKK            77            DKK200,281
#> 57  2022-10-17           DKK            77            DKK200,281
#> 58  2022-10-17           DKK            77            DKK200,281
#> 59  2022-10-17           DKK            77            DKK200,281
#> 60  2022-10-17           DKK            77            DKK200,281
#> 61  2022-10-17           DKK            77            DKK200,281
#> 62  2022-10-17           DKK            77            DKK200,281
#> 63  2022-10-17           DKK            77            DKK200,281
#> 64  2022-10-17           DKK            77            DKK200,281
#> 65  2022-10-17           DKK            77            DKK200,281
#> 66  2022-10-17           DKK            77            DKK200,281
#> 67  2022-10-17           DKK            77            DKK200,281
#> 68  2022-10-17           DKK            77            DKK200,281
#> 69  2022-10-17           DKK            77            DKK200,281
#> 70  2022-10-17           DKK            77            DKK200,281
#> 71  2022-10-17           DKK            77            DKK200,281
#> 72  2022-10-17           DKK            77            DKK200,281
#> 73  2022-10-17           DKK            77            DKK200,281
#> 74  2022-10-17           DKK            77            DKK200,281
#> 75  2022-10-17           DKK            77            DKK200,281
#> 76  2022-10-17           DKK            77            DKK200,281
#> 77  2022-10-17           DKK            77            DKK200,281
#> 78  2022-10-17           DKK            77            DKK200,281
#> 79  2022-10-17           DKK            77            DKK200,281
#> 80  2022-10-17           DKK            77            DKK200,281
#> 81  2022-10-17           DKK            77            DKK200,281
#> 82  2022-10-17           DKK            77            DKK200,281
#> 83  2022-10-17           DKK            77            DKK200,281
#> 84  2022-10-17           DKK            77            DKK200,281
#> 85  2022-10-17           DKK            77            DKK200,281
#> 86  2022-10-17           DKK            77            DKK200,281
#> 87  2022-10-17           DKK            77            DKK200,281
#> 88  2022-10-17           DKK            77            DKK200,281
#> 89  2022-10-17           DKK            77            DKK200,281
#> 90  2022-10-17           DKK            77            DKK200,281
#> 91  2022-10-17           DKK            77            DKK200,281
#> 92  2022-10-17           DKK            77            DKK200,281
#> 93  2022-10-17           DKK            77            DKK200,281
#> 94  2022-10-17           DKK            77            DKK200,281
#> 95  2022-10-17           DKK            77            DKK200,281
#> 96  2022-10-17           DKK            77            DKK200,281
#> 97  2022-10-17           DKK            77            DKK200,281
#> 98  2022-10-17           DKK            77            DKK200,281
#> 99  2022-10-17           DKK            77            DKK200,281
#> 100 2022-10-17           DKK            77            DKK200,281
#> 101 2022-10-17           DKK            77            DKK200,281
#> 102 2022-10-17           DKK            77            DKK200,281
#> 103 2022-10-17           DKK            77            DKK200,281
#> 104 2022-10-17           DKK            77            DKK200,281
#> 105 2022-10-17           DKK            77            DKK200,281
#> 106 2022-10-17           DKK            77            DKK200,281
#> 107 2022-10-17           DKK            77            DKK200,281
#> 108 2022-10-17           DKK            77            DKK200,281
#> 109 2022-10-17           DKK            77            DKK200,281
#> 110 2022-10-17           DKK            77            DKK200,281
#> 111 2022-10-17           DKK            77            DKK200,281
#> 112 2022-10-17           DKK            77            DKK200,281
#> 113 2022-10-17           DKK            77            DKK200,281
#> 114 2022-10-17           DKK            77            DKK200,281
#> 115 2022-10-17           DKK            77            DKK200,281
#> 116 2022-10-17           DKK            77            DKK200,281
#> 117 2022-10-17           DKK            77            DKK200,281
#> 118 2022-10-17           DKK            77            DKK200,281
#> 119 2022-10-17           DKK            77            DKK200,281
#> 120 2022-10-17           DKK            77            DKK200,281
#> 121 2022-10-17           DKK            77            DKK200,281
#> 122 2022-10-17           DKK            77            DKK200,281
#> 123 2022-10-17           DKK            77            DKK200,281
#> 124 2022-10-17           DKK            77            DKK200,281
#> 125 2022-10-17           DKK            77            DKK200,281
#> 126 2022-10-17           DKK            77            DKK200,281
#> 127 2022-10-17           DKK            77            DKK200,281
#> 128 2022-10-17           DKK            77            DKK200,281
#> 129 2022-10-17           DKK            77            DKK200,281
#> 130 2022-10-17           DKK            77            DKK200,281
#> 131 2022-10-17           DKK            77            DKK200,281
#> 132 2022-10-17           DKK            77            DKK200,281
#> 133 2022-10-17           DKK            77            DKK200,281
#> 134 2022-10-17           DKK            77            DKK200,281
#> 135 2022-10-17           DKK            77            DKK200,281
#> 136 2022-10-17           DKK            77            DKK200,281
#> 137 2022-10-17           DKK            77            DKK200,281
#> 138 2022-10-17           DKK            77            DKK200,281
#> 139 2022-10-17           DKK            77            DKK200,281
#> 140 2022-10-17           DKK            77            DKK200,281
#> 141 2022-10-17           DKK            77            DKK200,281
#> 142 2022-10-17           DKK            77            DKK200,281
#> 143 2022-10-17           DKK            77            DKK200,281
#> 144 2022-10-17           DKK            77            DKK200,281
#> 145 2022-10-17           DKK            77            DKK200,281
#> 146 2022-10-17           DKK            77            DKK200,281
#> 147 2022-10-17           DKK            77            DKK200,281
#> 148 2022-10-17           DKK            77            DKK200,281
#> 149 2022-10-17           DKK            77            DKK200,281
#> 150 2022-10-17           DKK            77            DKK200,281
#> 151 2022-10-17           DKK            77            DKK200,281
#> 152 2022-10-17           DKK            77            DKK200,281
#> 153 2022-10-17           DKK            77            DKK200,281
#> 154 2022-10-17           DKK            77            DKK200,281
#> 155 2022-10-17           DKK            77            DKK200,281
#> 156 2022-10-17           DKK            77            DKK200,281
#> 157 2022-10-17           DKK            77            DKK200,281
#> 158 2022-10-17           DKK            77            DKK200,281
#> 159 2022-10-17           DKK            77            DKK200,281
#> 160 2022-10-17           DKK            77            DKK200,281
#> 161 2022-10-17           DKK            77            DKK200,281
#> 162 2022-10-17           DKK            77            DKK200,281
#> 163 2022-10-17           DKK            77            DKK200,281
#> 164 2022-10-17           DKK            77            DKK200,281
#> 165 2022-10-17           DKK            77            DKK200,281
#> 166 2022-10-17           DKK            77            DKK200,281
#> 167 2022-10-17           DKK            77            DKK200,281
#> 168 2022-10-17           DKK            77            DKK200,281
#> 169 2022-10-17           DKK            77            DKK200,281
#> 170 2022-10-17           DKK            77            DKK200,281
#> 171 2022-10-17           DKK            77            DKK200,281
#> 172 2022-10-17           DKK            77            DKK200,281
#> 173 2022-10-17           DKK            77            DKK200,281
#> 174 2022-10-17           DKK            77            DKK200,281
#> 175 2022-10-17           DKK            77            DKK200,281
#> 176 2022-10-17           DKK            77            DKK200,281
#> 177 2022-10-17           DKK            77            DKK200,281
#> 178 2022-10-17           DKK            77            DKK200,281
#> 179 2022-10-17           DKK            77            DKK200,281
#> 180 2022-10-17           DKK            77            DKK200,281
#> 181 2022-10-17           DKK            77            DKK200,281
#> 182 2022-10-17           DKK            77            DKK200,281
#> 183 2022-10-17           DKK            77            DKK200,281
#>     is_30_day_available is_90_day_available internal_id
#> 1                  TRUE                TRUE 41459763029
#> 2                  TRUE                TRUE 41459763029
#> 3                  TRUE                TRUE 41459763029
#> 4                  TRUE                TRUE 41459763029
#> 5                  TRUE                TRUE 41459763029
#> 6                  TRUE                TRUE 41459763029
#> 7                  TRUE                TRUE 41459763029
#> 8                  TRUE                TRUE 41459763029
#> 9                  TRUE                TRUE 41459763029
#> 10                 TRUE                TRUE 41459763029
#> 11                 TRUE                TRUE 41459763029
#> 12                 TRUE                TRUE 41459763029
#> 13                 TRUE                TRUE 41459763029
#> 14                 TRUE                TRUE 41459763029
#> 15                 TRUE                TRUE 41459763029
#> 16                 TRUE                TRUE 41459763029
#> 17                 TRUE                TRUE 41459763029
#> 18                 TRUE                TRUE 41459763029
#> 19                 TRUE                TRUE 41459763029
#> 20                 TRUE                TRUE 41459763029
#> 21                 TRUE                TRUE 41459763029
#> 22                 TRUE                TRUE 41459763029
#> 23                 TRUE                TRUE 41459763029
#> 24                 TRUE                TRUE 41459763029
#> 25                 TRUE                TRUE 41459763029
#> 26                 TRUE                TRUE 41459763029
#> 27                 TRUE                TRUE 41459763029
#> 28                 TRUE                TRUE 41459763029
#> 29                 TRUE                TRUE 41459763029
#> 30                 TRUE                TRUE 41459763029
#> 31                 TRUE                TRUE 41459763029
#> 32                 TRUE                TRUE 41459763029
#> 33                 TRUE                TRUE 41459763029
#> 34                 TRUE                TRUE 41459763029
#> 35                 TRUE                TRUE 41459763029
#> 36                 TRUE                TRUE 41459763029
#> 37                 TRUE                TRUE 41459763029
#> 38                 TRUE                TRUE 41459763029
#> 39                 TRUE                TRUE 41459763029
#> 40                 TRUE                TRUE 41459763029
#> 41                 TRUE                TRUE 41459763029
#> 42                 TRUE                TRUE 41459763029
#> 43                 TRUE                TRUE 41459763029
#> 44                 TRUE                TRUE 41459763029
#> 45                 TRUE                TRUE 41459763029
#> 46                 TRUE                TRUE 41459763029
#> 47                 TRUE                TRUE 41459763029
#> 48                 TRUE                TRUE 41459763029
#> 49                 TRUE                TRUE 41459763029
#> 50                 TRUE                TRUE 41459763029
#> 51                 TRUE                TRUE 41459763029
#> 52                 TRUE                TRUE 41459763029
#> 53                 TRUE                TRUE 41459763029
#> 54                 TRUE                TRUE 41459763029
#> 55                 TRUE                TRUE 41459763029
#> 56                 TRUE                TRUE 41459763029
#> 57                 TRUE                TRUE 41459763029
#> 58                 TRUE                TRUE 41459763029
#> 59                 TRUE                TRUE 41459763029
#> 60                 TRUE                TRUE 41459763029
#> 61                 TRUE                TRUE 41459763029
#> 62                 TRUE                TRUE 41459763029
#> 63                 TRUE                TRUE 41459763029
#> 64                 TRUE                TRUE 41459763029
#> 65                 TRUE                TRUE 41459763029
#> 66                 TRUE                TRUE 41459763029
#> 67                 TRUE                TRUE 41459763029
#> 68                 TRUE                TRUE 41459763029
#> 69                 TRUE                TRUE 41459763029
#> 70                 TRUE                TRUE 41459763029
#> 71                 TRUE                TRUE 41459763029
#> 72                 TRUE                TRUE 41459763029
#> 73                 TRUE                TRUE 41459763029
#> 74                 TRUE                TRUE 41459763029
#> 75                 TRUE                TRUE 41459763029
#> 76                 TRUE                TRUE 41459763029
#> 77                 TRUE                TRUE 41459763029
#> 78                 TRUE                TRUE 41459763029
#> 79                 TRUE                TRUE 41459763029
#> 80                 TRUE                TRUE 41459763029
#> 81                 TRUE                TRUE 41459763029
#> 82                 TRUE                TRUE 41459763029
#> 83                 TRUE                TRUE 41459763029
#> 84                 TRUE                TRUE 41459763029
#> 85                 TRUE                TRUE 41459763029
#> 86                 TRUE                TRUE 41459763029
#> 87                 TRUE                TRUE 41459763029
#> 88                 TRUE                TRUE 41459763029
#> 89                 TRUE                TRUE 41459763029
#> 90                 TRUE                TRUE 41459763029
#> 91                 TRUE                TRUE 41459763029
#> 92                 TRUE                TRUE 41459763029
#> 93                 TRUE                TRUE 41459763029
#> 94                 TRUE                TRUE 41459763029
#> 95                 TRUE                TRUE 41459763029
#> 96                 TRUE                TRUE 41459763029
#> 97                 TRUE                TRUE 41459763029
#> 98                 TRUE                TRUE 41459763029
#> 99                 TRUE                TRUE 41459763029
#> 100                TRUE                TRUE 41459763029
#> 101                TRUE                TRUE 41459763029
#> 102                TRUE                TRUE 41459763029
#> 103                TRUE                TRUE 41459763029
#> 104                TRUE                TRUE 41459763029
#> 105                TRUE                TRUE 41459763029
#> 106                TRUE                TRUE 41459763029
#> 107                TRUE                TRUE 41459763029
#> 108                TRUE                TRUE 41459763029
#> 109                TRUE                TRUE 41459763029
#> 110                TRUE                TRUE 41459763029
#> 111                TRUE                TRUE 41459763029
#> 112                TRUE                TRUE 41459763029
#> 113                TRUE                TRUE 41459763029
#> 114                TRUE                TRUE 41459763029
#> 115                TRUE                TRUE 41459763029
#> 116                TRUE                TRUE 41459763029
#> 117                TRUE                TRUE 41459763029
#> 118                TRUE                TRUE 41459763029
#> 119                TRUE                TRUE 41459763029
#> 120                TRUE                TRUE 41459763029
#> 121                TRUE                TRUE 41459763029
#> 122                TRUE                TRUE 41459763029
#> 123                TRUE                TRUE 41459763029
#> 124                TRUE                TRUE 41459763029
#> 125                TRUE                TRUE 41459763029
#> 126                TRUE                TRUE 41459763029
#> 127                TRUE                TRUE 41459763029
#> 128                TRUE                TRUE 41459763029
#> 129                TRUE                TRUE 41459763029
#> 130                TRUE                TRUE 41459763029
#> 131                TRUE                TRUE 41459763029
#> 132                TRUE                TRUE 41459763029
#> 133                TRUE                TRUE 41459763029
#> 134                TRUE                TRUE 41459763029
#> 135                TRUE                TRUE 41459763029
#> 136                TRUE                TRUE 41459763029
#> 137                TRUE                TRUE 41459763029
#> 138                TRUE                TRUE 41459763029
#> 139                TRUE                TRUE 41459763029
#> 140                TRUE                TRUE 41459763029
#> 141                TRUE                TRUE 41459763029
#> 142                TRUE                TRUE 41459763029
#> 143                TRUE                TRUE 41459763029
#> 144                TRUE                TRUE 41459763029
#> 145                TRUE                TRUE 41459763029
#> 146                TRUE                TRUE 41459763029
#> 147                TRUE                TRUE 41459763029
#> 148                TRUE                TRUE 41459763029
#> 149                TRUE                TRUE 41459763029
#> 150                TRUE                TRUE 41459763029
#> 151                TRUE                TRUE 41459763029
#> 152                TRUE                TRUE 41459763029
#> 153                TRUE                TRUE 41459763029
#> 154                TRUE                TRUE 41459763029
#> 155                TRUE                TRUE 41459763029
#> 156                TRUE                TRUE 41459763029
#> 157                TRUE                TRUE 41459763029
#> 158                TRUE                TRUE 41459763029
#> 159                TRUE                TRUE 41459763029
#> 160                TRUE                TRUE 41459763029
#> 161                TRUE                TRUE 41459763029
#> 162                TRUE                TRUE 41459763029
#> 163                TRUE                TRUE 41459763029
#> 164                TRUE                TRUE 41459763029
#> 165                TRUE                TRUE 41459763029
#> 166                TRUE                TRUE 41459763029
#> 167                TRUE                TRUE 41459763029
#> 168                TRUE                TRUE 41459763029
#> 169                TRUE                TRUE 41459763029
#> 170                TRUE                TRUE 41459763029
#> 171                TRUE                TRUE 41459763029
#> 172                TRUE                TRUE 41459763029
#> 173                TRUE                TRUE 41459763029
#> 174                TRUE                TRUE 41459763029
#> 175                TRUE                TRUE 41459763029
#> 176                TRUE                TRUE 41459763029
#> 177                TRUE                TRUE 41459763029
#> 178                TRUE                TRUE 41459763029
#> 179                TRUE                TRUE 41459763029
#> 180                TRUE                TRUE 41459763029
#> 181                TRUE                TRUE 41459763029
#> 182                TRUE                TRUE 41459763029
#> 183                TRUE                TRUE 41459763029
```
