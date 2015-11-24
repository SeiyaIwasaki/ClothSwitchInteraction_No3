/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/

import processing.serial.*;

Serial port;

/*
* 構成位置の数は Arduino 側のプログラムと
* Processing 側のプログラムで一致させる必要がある
*/
final int fps = 30;
final int position_qty = 1;                                     // 構成位置の数（着脱位置の数）
long capVal[][] = new long[position_qty][4];                    // 静電容量の測定値
OperationDetect opeDet[] = new OperationDetect[position_qty];   // 操作検出クラス
int analogValues[] = new int[position_qty];

void setup(){
    /*--- Arduino 設定 ---*/

    // シリアルポートの設定
    printArray(Serial.list());                // シリアルポート一覧
    String portName = Serial.list()[1];    // Arduinoと接続しているシリアルを選択
    port = new Serial(this, portName, 9600);  


    /*--- 操作検出クラス初期化 & リスナー登録 ---*/
    for(int i = 0; i < position_qty; i++){
        opeDet[i] = new OperationDetect(100, 30, fps);
    }
    setListeners();


    /*--- アプリケーション設定 ---*/

    // 画面設定
    size(displayWidth, displayHeight);
    noStroke();
    smooth();
    frameRate(fps);
    imageMode(CENTER);
    ellipseMode(CENTER);
    colorMode(RGB, 256, 256, 256, 256);

}


/*-- 静電容量の測定値を入力し，ユーザのアクションを検出 --*/
void detectAction(){
    for(int i = 0; i < position_qty; i++){
        opeDet[i].inputCapValue(capVal[i]);
    }
    // 各構成位置のアクションを検出
    for(int i = 0; i < position_qty; i++){
        opeDet[i].operationDetect();
    }
}

void draw(){
    background(#ffffff);

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
            if(value.length >= position_qty * 5){
                for(int i = 0; i < position_qty; i++){
                    analogValues[i] = value[i * 4];
                    capVal[i][0] = value[i * 4 + 1];
                    capVal[i][1] = value[i * 4 + 2];
                    capVal[i][2] = value[i * 4 + 3];
                    capVal[i][3] = value[i * 4 + 4];
                }
            }
        }
    }catch(Exception e){
        e.printStackTrace();
    }
    detectAction();
}


/*-- リスナー登録（匿名クラス） --*/
void setListeners(){
    // 構成位置 No.1
    if(position_qty > 0){
        opeDet[0].setOnActionListener(new OnActionListener(){
            @Override // タッチ
            public void onTouch(int direction){

            }

            @Override // 左右スライド
            public void onLRSwipe(int direction){

            }

            @Override // 上下スライド
            public void onUDSwipe(int direction){

            }

            @Override // ホイール
            public void onWheel(int direction){

            }
        });
    }
}

