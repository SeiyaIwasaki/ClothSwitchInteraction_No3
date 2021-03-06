/******************************************
	Reconfigurable Interaction
	No.3
	2015 Seiya Iwasaki
******************************************/

#include <CapacitiveSensor.h>				// 静電容量センサライブラリ

#define SAMPLING 10					// 静電容量をセンシングする際のサンプリング数
#define BUFFER_LENGTH 5                                 // バッファサイズ

/*
* 構成位置の数は Arduino 側のプログラムと
* Processing 側のプログラムで一致させる必要がある
*/
const int position_qty = 2;				// 構成位置の数（着脱位置の数）
long capVal[position_qty][4];				// 静電容量の測定値
CapacitiveSensor *sensor[position_qty][4];	        // 静電容量センサオブジェクト
int analogValues[position_qty * 2][BUFFER_LENGTH];      // アナログ電圧
int index = 0;

void setup(){
        sensor[0][0] = new CapacitiveSensor(2, 3);
        sensor[0][1] = new CapacitiveSensor(2, 4);
        sensor[0][2] = new CapacitiveSensor(2, 5);
        sensor[0][3] = new CapacitiveSensor(2, 6);
        sensor[1][0] = new CapacitiveSensor(9, 10);
        sensor[1][1] = new CapacitiveSensor(9, 11);
        sensor[1][2] = new CapacitiveSensor(9, 12);
        sensor[1][3] = new CapacitiveSensor(9, 13);
    
	// 静電容量センサの初期化
	for(int i = 0; i < position_qty; i++){
//		int j = 2 + i * 5;
//		sensor[i][0] = new CapacitiveSensor(j, j + 1);	// 電極 A
//		sensor[i][1] = new CapacitiveSensor(j, j + 2);	// 電極 B
//		sensor[i][2] = new CapacitiveSensor(j, j + 3);	// 電極 C
//		sensor[i][3] = new CapacitiveSensor(j, j + 4);	// 電極 D
                // キャリブレーション (オートキャリブレーションOFF)
                sensor[i][0]->set_CS_AutocaL_Millis(0xFFFFFFFF);
                sensor[i][1]->set_CS_AutocaL_Millis(0xFFFFFFFF);
                sensor[i][2]->set_CS_AutocaL_Millis(0xFFFFFFFF);
                sensor[i][3]->set_CS_AutocaL_Millis(0xFFFFFFFF);
                sensor[i][0]->reset_CS_AutoCal();
                sensor[i][1]->reset_CS_AutoCal();
                sensor[i][2]->reset_CS_AutoCal();
                sensor[i][3]->reset_CS_AutoCal();
	}

	// シリアル通信
	Serial.begin(9600);
}

void loop(){
	// 静電容量の測定
	for(int i = 0; i < position_qty; i++){
		for(int j = 0; j < 4; j++){
			capVal[i][j] = sensor[i][j]->capacitiveSensor(SAMPLING);
			delay(10);
		}
	}

        // 電圧値の測定
        for(int i = 0; i < position_qty * 2; i++){
            analogRead(i);
            analogRead(i);
            int raw = analogRead(i);
            analogValues[i][index] = raw;   
        }
        index = (index + 1) % BUFFER_LENGTH;

	// 測定値をシリアル通信で送信
	for(int i = 0; i < position_qty; i++){
                Serial.print(smoothByMeanFilter(analogValues[i * position_qty]));
                Serial.print(',');
                Serial.print(smoothByMeanFilter(analogValues[i * position_qty + 1]));
                Serial.print(',');
		for(int j = 0; j < 4; j++){
			Serial.print(capVal[i][j]);
			Serial.print(',');
		}
	}
	Serial.println();
}

int smoothByMeanFilter(int *box){
    int sum = 0;
    for(int i = 0; i < BUFFER_LENGTH; i++){
        sum += box[i];
    }
    return (int)(sum / BUFFER_LENGTH);
}
