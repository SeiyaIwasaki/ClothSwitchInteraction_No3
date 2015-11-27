/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/

import processing.serial.*;
import ddf.minim.*;
import ddf.minim.effects.*;
import java.awt.Rectangle;
import java.awt.Point;
import java.util.Arrays;

Serial port;

/*
* 構成位置の数は Arduino 側のプログラムと
* Processing 側のプログラムで一致させる必要がある
*/
final int fps = 30;
final int area_qty = 2;                                             // 構成位置の数（着脱位置の数）
final int posInArea_qty = 2;                                        // 機能布スイッチ貼付位置の数 / エリア
final int functionSwitch_qty = 4;                                   // 機能を持つスイッチの数
int switchRange[][] = new int[functionSwitch_qty][2];               // スイッチから得られるアナログ入力値の範囲
long capVal[][] = new long[area_qty][4];                            // 静電容量の測定値
OperationDetect opeDet[] = new OperationDetect[area_qty];           // 操作検出クラス
int analogValues[] = new int[area_qty * posInArea_qty];             // 各構成位置のアナログ入力値
int functionDetect[][] = new int[area_qty * posInArea_qty][5];      // 各構成位置が持つ機能のIDを過去5つ分まで格納
int functionIndex = 0;
Object positionFunction[] = new Object[area_qty * posInArea_qty];   // 各構成位置に機能を紐付ける

Minim minim;

void setup(){
    /*--- 操作検出クラス初期化 & リスナー登録 ---*/
    for(int i = 0; i < area_qty; i++){
        opeDet[i] = new OperationDetect(100, 30, fps);
    }
    setListeners();
    minim = new Minim(this);
    setupTaroBook();
    taroBook.resizePageImage((int)(width / 2 * 0.6));
    setupChloeBook();
    chloeBook.resizePageImage((int)(width / 2 * 0.6));

    // 各スイッチの電圧幅の初期化
    initSwitchRange();
    
    // 機能布スイッチ検出結果のバッファを初期化
    for(int i = 0; i < area_qty * posInArea_qty; i++){
        for(int j = 0; j < 5; j++){
            functionDetect[i][j] = -1;  
        }
    }


    /*--- アプリケーション設定 ---*/

    // 画面設定
    size(displayWidth, displayHeight);
    noStroke();
    smooth();
    frameRate(fps);
    imageMode(CENTER);
    ellipseMode(CENTER);
    colorMode(RGB, 256, 256, 256, 256);


    /*--- Arduino 設定 ---*/

    // シリアルポートの設定
    printArray(Serial.list());             // シリアルポート一覧
    String portName = Serial.list()[2];    // Arduinoと接続しているシリアルを選択
    port = new Serial(this, portName, 9600);  

}

void draw(){
    background(#ffffff);
    
    // 各構成位置で有効になっている機能の描画処理
    for(int i = 0; i < area_qty * posInArea_qty; i++){
        if(positionFunction[i] != null){
            drawFunctions(i, getActiveFunction(functionDetect[i]));
        }
    }
    
    // アプリ画面区分け
    textSize(24);
    textAlign(CENTER);
    fill(#3c3c3c);
    text("Area [1]", width / area_qty * 0.5, 70);
    
    textSize(24);
    textAlign(CENTER);
    fill(#3c3c3c);
    text("Area [2]", width / area_qty * 1.5, 70);
    
    stroke(#888888);
    strokeWeight(2);
    line(width / area_qty, 0, width / area_qty, height);
    noStroke();
    
    // DEBUG
    if(frameRate < fps - 5){
        textSize(18);
        textAlign(LEFT);
        fill(#ee2c2c);
        text("Now, System Instability\nfps:" + str(floor(frameRate)), 20, 20);
    }
}


/*-- 機能クラスが持っている描画処理を実行する --*/
void drawFunctions(int position, int id){
    switch(id){
        case 0:     // ミュージックプレイヤー
            ((AppMusicControler)positionFunction[position]).draw();
            break;
        case 1:     // ブックプレイヤー
            ((AppBookPlayer)positionFunction[position]).draw();
            break; 
    }
}


/*-- 機能クラスの終了処理 --*/
void stopFunctions(int position){
    if(positionFunction[position] instanceof AppMusicControler == true){
        /* ミュージックプレイヤー */
        ((AppMusicControler)positionFunction[position]).stop();
    }else if(positionFunction[position] instanceof UserInformation == true){
        /* ユーザー設定クラス */
        removeSetting(position);
    }
    positionFunction[position] = null;
}

    
/*-- 静電容量の測定値を入力し，ユーザのアクションを検出 --*/
void detectAction(){
    for(int i = 0; i < area_qty; i++){
        opeDet[i].inputCapValue(capVal[i]);
    }
    // 各構成位置のアクションを検出
    for(int i = 0; i < area_qty; i++){
        opeDet[i].operationDetect();
    }
    /****** たまにここでnull Error発生 *******/
}


/*-- 各構成位置に対して得られた機能IDに対応する機能クラスを紐付ける --*/
void getFunctionLink(int position, int id){
    switch(id){
        case -1:    // 機能を持たない（スイッチが貼付されていない）
            if(positionFunction[position] != null){
                stopFunctions(position);
                positionFunction[position] = null;
            }
            break;
        case 0:     // ミュージックプレイヤー
            if(positionFunction[position] == null){
                positionFunction[position] = new AppMusicControler(minim);
                int pos = floor(position / 2);
                ((AppMusicControler)positionFunction[position]).inputPosition(pos + 1, area_qty);
            reflectSetting(position);
            }
            break;
        case 1:     // ブックプレイヤー
            if(positionFunction[position] == null){
                positionFunction[position] = new AppBookPlayer();
                int pos = floor(position / 2);
                ((AppBookPlayer)positionFunction[position]).inputPosition(pos + 1, area_qty);
            reflectSetting(position);
            }
            break;
        case 2:     // ユーザー設定 1 : Taro
            if(positionFunction[position] == null){
                positionFunction[position] = new UserInformation("Taro", "male", 14, "Japan");
                ((UserInformation)positionFunction[position]).addPlaylist(taroList);
                ((UserInformation)positionFunction[position]).addBook(taroBook);
            reflectSetting(position);
            }
            break;
        case 3:     // ユーザー設定 2 : Chloe
            if(positionFunction[position] == null){
                positionFunction[position] = new UserInformation("Chloe", "female", 18, "Australia");
                ((UserInformation)positionFunction[position]).addPlaylist(chloeList);
                ((UserInformation)positionFunction[position]).addBook(chloeBook);
            reflectSetting(position);
            }
            break;
    }
}

/*-- 布スイッチの持つユーザ設定を各機能に反映する --*/
private void reflectSetting(int position){
    // どのエリアに属するか確認
    int containsArea;
    for(containsArea = 0 ; containsArea < area_qty; containsArea++){
        if(posInArea_qty * containsArea <= position && position < posInArea_qty * (containsArea + 1)){
            break;
        }
    }

    // そのエリアに貼付されているユーザ設定情報を取得する
    Object userSetting = null;
    for(int i = containsArea * posInArea_qty; i < containsArea * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof UserInformation == true){
            userSetting = positionFunction[i];
            break;
        }
    }
    if(userSetting == null) return;

    // そのエリアに貼付されている機能布スイッチにユーザー設定を反映
    for(int i = containsArea * posInArea_qty; i < containsArea * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof AppMusicControler == true){
            ((AppMusicControler)positionFunction[i]).inputPlaylist(((UserInformation)userSetting).getPlaylist());
        }else if(positionFunction[i] instanceof AppBookPlayer == true){
            ((AppBookPlayer)positionFunction[i]).inputBook(((UserInformation)userSetting).getBook());
        }
    }
}


/*-- 各機能の持つユーザー設定を初期化 --*/
private void removeSetting(int position){
    // どのエリアに属するか確認
    int containsArea;
    for(containsArea = 0 ; containsArea < area_qty; containsArea++){
        if(posInArea_qty * containsArea <= position && position < posInArea_qty * (containsArea + 1)){
            break;
        }
    }

    // そのエリアに貼付されている機能布スイッチにユーザー設定を反映
    for(int i = containsArea * posInArea_qty; i < containsArea * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof AppMusicControler == true){
            ((AppMusicControler)positionFunction[i]).initPlaylist();
        }else if(positionFunction[i] instanceof AppBookPlayer == true){
            ((AppBookPlayer)positionFunction[i]).initBook();
        }
    }
}


/*-- スイッチの持つ機能IDを認識 --*/
void detectFunction(){
    for(int i = 0; i < area_qty * posInArea_qty; i++){
        functionDetect[i][functionIndex] = getFunctionID(analogValues[i]);
        getFunctionLink(i, getActiveFunction(functionDetect[i]));
        // println(i + " : " + getActiveFunction(functionDetect[i]));
    }
    println();
    functionIndex = (functionIndex + 1) % 5;
}


/*-- Touch Function --*/
void touchFunction(int area, int direction){
    // そのエリアに貼付されている機能布スイッチに操作を反映
    for(int i = area * posInArea_qty; i < area * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof AppMusicControler == true){
            ((AppMusicControler)positionFunction[i]).turnPlaying();
        }
    }
}


/*-- LRSwipe Function --*/
void lrSwipeFunction(int area, int direction){
    // そのエリアに貼付されている機能布スイッチに操作を反映
    for(int i = area * posInArea_qty; i < area * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof AppMusicControler == true){
            ((AppMusicControler)positionFunction[i]).changeMusic(direction);
        }else if(positionFunction[i] instanceof AppBookPlayer == true){
            ((AppBookPlayer)positionFunction[i]).changePage(direction);
        }
    }
}


/*-- UDSwipe Function --*/
void udSwipeFunction(int area, int direction){
    // そのエリアに貼付されている機能布スイッチに操作を反映
    for(int i = area * posInArea_qty; i < area * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof AppMusicControler == true){
            // ((AppMusicControler)positionFunction[i]).changePlaylist(direction);
        }
    }
}


/*-- wheel Function --*/
void wheelFunction(int area, int direction){
    // そのエリアに貼付されている機能布スイッチに操作を反映
    for(int i = area * posInArea_qty; i < area * posInArea_qty + posInArea_qty; i++){
        if(positionFunction[i] instanceof AppMusicControler == true){
            ((AppMusicControler)positionFunction[i]).changeVolume(direction);
        }
    }
}


/*-- リスナー登録（匿名クラス） --*/
void setListeners(){
    // 構成位置 No.1
    if(area_qty > 0){
        opeDet[0].setOnActionListener(new OnActionListener(){
            @Override // タッチ
            public void onTouch(int direction){
                touchFunction(0, direction);                
            }

            @Override // 左右スライド
            public void onLRSwipe(int direction){
                lrSwipeFunction(0, direction);
            }

            @Override // 上下スライド
            public void onUDSwipe(int direction){
                udSwipeFunction(0, direction);
            }

            @Override // ホイール
            public void onWheel(int direction){
                wheelFunction(0, direction);
            }
        });
    }
    
    // 構成位置 No.2
    if(area_qty > 1){
        opeDet[1].setOnActionListener(new OnActionListener(){
            @Override // タッチ
            public void onTouch(int direction){
                touchFunction(1, direction);
            }

            @Override // 左右スライド
            public void onLRSwipe(int direction){
                lrSwipeFunction(1, direction);
            }

            @Override // 上下スライド
            public void onUDSwipe(int direction){
                udSwipeFunction(1, direction);
            }

            @Override // ホイール
            public void onWheel(int direction){
                wheelFunction(1, direction);
            }
        });
    }
}


/*-- 現在，有効になっている機能IDを返す --*/
int getActiveFunction(int[] box){    
    int[] counter = new int[functionSwitch_qty + 1];
    for(int i = 0; i < counter.length; i++){
        counter[i] = 0;   
    }
    for(int i = 0; i < box.length; i++){
        counter[box[i] + 1]++;   
    }
    int[] sorted = reverse(sort(counter));
    
    int afID = 0;
    for(int i = 0; i < counter.length; i++){
        if(counter[i] == sorted[0]){
            afID = i - 1;
            break;
        }
    }
    return afID;
}


/*-- 電圧値に対応する機能IDを返す --*/
int getFunctionID(int Ain){
    if(Ain > 1015) return -1;
    for(int i = 0; i < functionSwitch_qty; i++){
        if(switchRange[i][0] <= Ain && Ain <= switchRange[i][1]){
            return i;
        }
    }
    return -1;
}


/*-- 各スイッチの電圧範囲の初期化 --*/
void initSwitchRange(){
    int i = 0;
    if(functionSwitch_qty > i){
        // [10k] スイッチ 0 : Music Player
        switchRange[i][0] = 510;     // min
        switchRange[i][1] = 560;     // max
        i++;
    }
    if(functionSwitch_qty > i){
        // [22k] スイッチ 1 : Book
        switchRange[i][0] = 700;     // min
        switchRange[i][1] = 720;     // max
        i++;
    }
    if(functionSwitch_qty > i){
        // [33k] スイッチ 2 : User Setting 1 (male)
        switchRange[i][0] = 780;     // min
        switchRange[i][1] = 800;     // max
        i++;
    }
    if(functionSwitch_qty > i){
        // [470k] スイッチ 3 : User Setting 2 (female)
        switchRange[i][0] = 995;     // min
        switchRange[i][1] = 1008;    // max
        i++;
    }
}


/*-- シリアル通信 --*/
void serialEvent(Serial p){
    // 改行区切りでデータを読み込む (¥n == 10)
    String inString = p.readStringUntil(10);
    try{
        // カンマ区切りのデータの文字列をパースして数値として読み込む
        if(inString != null){
            inString = trim(inString);
            int[] value = int(split(inString, ','));
            int rodeQtyOfBlock = posInArea_qty + 4;     // 一つのエリアごとに受信されるデータの数
            if(value.length >= area_qty * rodeQtyOfBlock){
                for(int i = 0; i < area_qty; i++){
                    analogValues[i * area_qty] = value[i * rodeQtyOfBlock];
                    analogValues[i * area_qty + 1] = value[i * rodeQtyOfBlock + 1];
                    capVal[i][0] = value[i * rodeQtyOfBlock + 2];
                    capVal[i][1] = value[i * rodeQtyOfBlock + 3];
                    capVal[i][2] = value[i * rodeQtyOfBlock + 4];
                    capVal[i][3] = value[i * rodeQtyOfBlock + 5];
                }
            }
        }
    }catch(Exception e){
        e.printStackTrace();
    }
    // printArray(analogValues);
    detectAction();
    detectFunction();
}

void stop(){
    minim.stop();
    super.stop();
}