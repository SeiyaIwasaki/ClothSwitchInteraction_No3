/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/

// 国籍リスト  
HashMap<String, Integer> countryS2I = new HashMap<String, Integer>(){
    {
        put("Japan", 1);
        put("US", 2);
        put("Australia", 3);
    }
};  
HashMap<Integer, String> countryI2S = new HashMap<Integer, String>(){
    {
        put(1, "Japan");
        put(2, "US");
        put(3, "Australia");
    }
};

// 性別リスト  
HashMap<String, Integer> genderS2I = new HashMap<String, Integer>(){
    {
        put("male", 1);
        put("female", 0);
    }
};  
HashMap<Integer, String> genderI2S = new HashMap<Integer, String>(){
    {
        put(1, "male");
        put(0, "female");
    }
};


/** ユーザー情報を保持するクラス **/
class UserInformation{
    /*-- Field --*/
    private String name;                            // 名前
    private int gender;                             // 性別  
    private int old;                                // 年齢   
    private int country;                            // 国籍       
    private Playlist playlist;                      // 音楽のプレイリスト（そのうちArrayListで）
    private Book book;                              // お気に入りの本

    /*-- Constracter --*/
    UserInformation(String name, String gender, int old, String country){
        this.name = name;
        this.gender = genderS2I.get(gender);
        this.old = old;
        this.country = countryS2I.get(country);
    }


    /*-- Method --*/

    // 名前の取得
    public String getName(){
        return name;
    }

    // 性別の取得
    public String getGender(){
        return genderI2S.get(gender);
    }
    public int getGenderID(){
        return gender;
    }

    // 年齢の取得
    public int getOld(){
        return old;
    }

    // 国籍の取得
    public String getCountry(){
        return countryI2S.get(country);
    }
    public int getCountryID(){
        return country;
    }

    // プレイリストの追加
    public void addPlaylist(Playlist list){
        this.playlist = list;
    }

    // プレイリストの取得
    public Playlist getPlaylist(){
        return playlist;
    }

    // 本の追加
    public void addBook(Book book){
        this.book = book;
    }

    // 本の取得
    public Book getBook(){
        return book;
    }
}