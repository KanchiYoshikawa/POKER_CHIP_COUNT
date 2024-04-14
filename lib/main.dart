import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Player {
  String playerName = '';
  int stack = 30000;
  String posision = '';//btnを判別するために使う
  String action = '';//今現在誰のアクションなのかを判別するために使う
  int betAmount = 0;//今のストリートでいくらベットしているのかを表示する
  bool actionColor = true;//プレイに参加しているのかFoldしているのかを判別する。
  bool allInMaker = false;//前のストリートでALLINしている場合にTrueにする。
  bool active = true;//プレイヤーがアクティブかを判別する（スタックがあるかどう）

  Player(this.playerName);

}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:pokerChipCount(),
    );
  }
}

class pokerChipCount extends StatefulWidget {
  const pokerChipCount({ Key? key }) : super(key: key);

  @override
  State<pokerChipCount> createState() => _pokerChipCountState();
}

class _pokerChipCountState extends State<pokerChipCount> {
  int pot = 0;
  List<Player>  players = [];
  String actionMessage = '';
  int actionPlayerNum = 0;
  final smallBlind = 100;
  final bigBlind = 200;
  int playerNum = 0;
  int street = 0;
  bool showdown = false;
  bool buttonActive = true;
  final betTextController = TextEditingController();
  int actionBetAmount = 0; //今アクションしているプレイヤーの（今のストリートでの）ベット金額
  List<int> actionPlayerList = [];
  List<int> allInPlayer = [];
  List<int> allInPlayerStreet = [];
  List<int> sidePot = [];
  List<int> sidePotStreet = [];
  bool allInFlg = false;
  int allInNum = 0;
  int streetPot = 0;
  int displayPot = 0;
  List displaySidePot = [];

  @override
  void initState() {
    int next = 1;
    for (var i = 0; i < 6; i++) {
      Player addPlayer = Player('Player' + (i+1).toString());
      players.add(addPlayer);
    }
    players[players.length - 1].posision = 'BTN';
    startNewGame();
    
    super.initState();
  }
  //ボタンのnumberを返す
  int returnBtnNumber(){
    int btnNum = 0;
    for (var i = 0; i < players.length; i++) {
      if(players[i].posision == 'BTN'){
        btnNum = i;
      }
    }
    return btnNum;
  }

  //今のストリートでbetされた総額を計算する
  void streetPotCulc(){
    streetPot = 0;
    for (Player player in players) {
      streetPot += player.betAmount;
    }
    displayPot = streetPot + pot;
  }

  //ALL IN が入っている場合のbet金額を計算する
  void streetPotAllInCulc(){
    int count = 0;
    int allInBet = 0;
    allInPlayerStreet = [];
    sidePotStreet = [];
    //allInPlayerを洗い出し、stackの小さい順に格納する
    for (Player player in players) {
      if(player.actionColor && !player.allInMaker && player.stack - player.betAmount == 0){
        if(allInPlayerStreet.length == 0){
          allInPlayerStreet.add(count);
        }else{
          for (int i=0; i<allInPlayerStreet.length; i++) {
            if(players[allInPlayerStreet[i]].stack > player.stack){
              //すでにALL INしているプレイヤーよりもスタックが小さい場合
              allInPlayerStreet.insert(i, count);
              break;
            }else if(players[allInPlayerStreet[i]].playerName == player.playerName){
              //ALL INのプレイヤーが同じ場合処理を抜ける
              break;
            }
            //allInPlayerの一番後ろになる場合の処理
            if(i + 1 == allInPlayerStreet.length){
              allInPlayerStreet.add(count);
            }
          }
        }
      }
      count++;
    }

    //サイドポットとメインポットの計算
    for(int i=0; i<allInPlayerStreet.length ; i++){
      int sidePotTemp = 0;
      for (Player player in players) {
        if(allInBet < player.betAmount){
          sidePotTemp += players[allInPlayerStreet[i]].betAmount - allInBet;
        }
      }
      if(allInBet == 0){
        sidePotTemp += pot;
      }
      allInBet = players[allInPlayerStreet[i]].betAmount;
      sidePotStreet.add(sidePotTemp);
    }
    streetPot = 0;
    for (Player player in players) {
      if(allInBet < player.betAmount){
        streetPot += player.betAmount - allInBet;
      }
    }
    displaySidePot = [];
    displaySidePot.addAll(sidePot);
    displaySidePot.addAll(sidePotStreet);
    displayPot = streetPot;
  }

  //actionPlayerNumに次のプレイヤーの番号を格納してPlayersリストのactionに値を格納する
  void nextActionPlayer(){
    int nextActionNum = 0;
    // streetPotCulc();
    actionBetAmount = 0;
    nextActionNum = actionPlayerNum;
    players[actionPlayerNum].action = '';

    while(true){
      nextActionNum = nextPlayer(nextActionNum);
      if(players[nextActionNum].actionColor){
        if(players[nextActionNum].stack == 0){
          actionPlayerNum += 1;
          actionPlayerList.add(nextActionNum);
        }else{
          players[nextActionNum].action = 'Action';
          break;
        }
      }
    }
    actionPlayerNum = nextActionNum;
    actionBetAmount = players[actionPlayerNum].betAmount;
    betTextController.text = players[actionPlayerNum].betAmount.toString();
  }

  //次のプレイヤーの番号を返す関数
  int nextPlayer(int nowPlayerNum){
    int nextPlayerNum = 0;
    if (nowPlayerNum == players.length - 1){
      nextPlayerNum = 0;
    }else{
      nextPlayerNum = nowPlayerNum + 1;
    }
    return nextPlayerNum;
  }

  //各プレイヤーのbetAmountを0にリセットする。
  void resetBetAmount(){
    for (var i = 0; i < players.length; i++) {
      players[i].betAmount = 0;
    }
  }

  //各プレイヤーのactionColorをtrueにリセットする。
  void resetActionColor(){
    for (var i = 0; i < players.length; i++) {
      players[i].actionColor = true;
      players[i].allInMaker = false;
    }
  }

  //各プレイヤーのactionColorをtrueにリセットする。
  void resetAction(){
    for (var i = 0; i < players.length; i++) {
      players[i].action = '';
    }
  }

  //ゲームの最初のブラインドの計算を行う関数
  void blindBetAction(int betNum){
    players[actionPlayerNum].betAmount += betNum;
    //pot += betNum;
    actionPlayerList = [];
    actionPlayerList.add(actionPlayerNum);
    playerNum = 1;
  }

  //コール、チェックした時の計算を行う関数
  void checkCallAction(){
    actionPlayerList.add(actionPlayerNum);
    if(players[actionPlayerList[0]].betAmount > 0){
      //callの場合のアクション
      if(players[actionPlayerNum].stack <= players[actionPlayerList[0]].betAmount){
        //callがALL INになる場合
        allInFlg = true;
        allInNum = actionPlayerNum;
        players[actionPlayerNum].betAmount = players[actionPlayerNum].stack;
        //pot += players[actionPlayerNum].betAmount;
      }else{
        //普通のcallの場合
        players[actionPlayerNum].betAmount = players[actionPlayerList[0]].betAmount;
      }
      if(allInFlg){
        //allInが入っている時の計算
        streetPotAllInCulc();
      }else{
        //allInが入っていないときの計算
        //pot += players[actionPlayerList[0]].betAmount - players[actionPlayerNum].betAmount;
        players[actionPlayerNum].betAmount = players[actionPlayerList[0]].betAmount;
        streetPotCulc();
        playerNum += 1;
      }
    }
  }
  //レイズ額の最小値を計算する関数
  int raiseAmountMin(){
    int returnAmount = 0;
    if(actionPlayerList.length == 0){
      returnAmount = bigBlind;
    }else if(players[actionPlayerList[0]].betAmount == 0){
      returnAmount = bigBlind;
    }else{
      returnAmount = players[actionPlayerList[0]].betAmount * 2 - players[actionPlayerNum].betAmount;
    }
    return returnAmount;
  }


  //レイズした時の計算を行う関数
  bool raiseAction(){
    int betText = int.tryParse(betTextController.text) ?? 0;
    if(betText < players[actionPlayerNum].stack){
      if(raiseAmountMin() <= betText){
        players[actionPlayerNum].betAmount = betText;
        //pot += players[actionPlayerNum].betAmount - actionBetAmount;
        streetPotCulc();
        actionPlayerList = [];
        actionPlayerList.add(actionPlayerNum);
        playerNum = 1;
        return true;
      }else{
        actionMessage = players[actionPlayerNum].playerName + '. Not enough bet amount. Please action one more.';
        return false;
      }
    }else{
      allInFlg = true;
      allInNum = actionPlayerNum;
      players[actionPlayerNum].betAmount = betText;
      //pot += players[actionPlayerNum].betAmount - actionBetAmount;
      streetPotCulc();
      actionPlayerList = [];
      actionPlayerList.add(actionPlayerNum);
      playerNum = 1;
      return true;
    }

  }

  //オールイン時のサイドポット計算
  // void allInCulc(){
  //   int sidePotTemp = 0;
  //   int potTemp = 0;
  //   if(allInPlayer.length == 0){
  //     //ALL INが前に入っていないときの処理
  //     allInPlayer.add(allInNum);
  //     //if(allInNum == actionPlayerNum){
  //     streetPot = 0;
  //     for (int i in actionPlayerList) {
  //       streetPot += players[i].betAmount - players[allInNum].betAmount;
  //       sidePotTemp += players[allInNum].betAmount;
  //     }
  //     // }else{
  //     //   stree += players[actionPlayerNum].betAmount;
  //     // }
  //     sidePot.add(sidePotTemp + pot);
  //     pot = 0;
  //   }else{
  //     if(allInNum == actionPlayerNum){
      
  //     }else{
  //       stree
  //       sidePot[0] += players[actionPlayerNum].betAmount
  //     }

  //     //ALL INが前に入っている場合の処理
  //     for (int p = 0; p < allInPlayer.length ; p++) {
  //       if(players[actionPlayerNum].betAmount + players[actionPlayerNum].stack >= players[allInPlayer[p]].betAmount + players[allInPlayer[p]].stack ){
  //         allInPlayer.add(actionPlayerNum);
  //       }else{
  //         allInPlayer.insert(p, actionPlayerNum);
  //       }
  //     }

  //   }      
  // }

  //ストリートの終わりにスタックからベット金額を引く
  void stackCulc(){
    for (Player player in players) {
      player.stack -= player.betAmount;
    }
  }

  //次のストリートに進む
  void nextStreet(){
    if(allInPlayerStreet.length > 0){
      streetPotAllInCulc();
      allInPlayer.addAll(allInPlayerStreet);
      allInPlayerStreet = [];
      sidePot.addAll(sidePotStreet);
      sidePotStreet = [];
      pot = streetPot;
      for (int i in allInPlayer) {
        players[i].allInMaker = true;
      }
    }else{
      streetPotCulc();
      pot = streetPot + pot;
    }
    stackCulc();
    resetAction();
    resetBetAmount();
    allInFlg = false;
    playerNum = 0;
    //リバーまでは次のアクションに進む。リバーの場合はショウダウン。
    if(street < 3){
      street += 1;
      actionPlayerNum = returnBtnNumber();
      nextActionPlayer();
      actionPlayerList = [];
      // actionPlayerList.add(actionPlayerNum);
    }else{
      street += 1;
      showdown = true;
      buttonActive = false;
    }
    actionMessageGenerate();
  }

  //アクションメッセージの文字生成
  void actionMessageGenerate(){
    if(street == 0){
      actionMessage = 'PreFrop  ' + players[actionPlayerNum].playerName + ' Action';
    }
    if(street == 1){
      actionMessage = 'Flop  ' + players[actionPlayerNum].playerName + ' Action';
    }
    if(street == 2){
      actionMessage = 'Turn  ' + players[actionPlayerNum].playerName + ' Action';
    }
    if(street == 3){
      actionMessage = 'Rever  ' + players[actionPlayerNum].playerName + ' Action';
    }
    if(street == 4){
      actionMessage = 'ShowDown. Please tap winning Player.';
    }
  }

  //次のゲームをスタートする（BTNを回してプリフロに進む）
  void startNewGame(){
    resetActionColor();
    resetBetAmount();
    resetAction();
    displayPot = 0;
    displaySidePot = [];
    allInFlg = false;
    buttonActive = true;
    street = 0;
    actionMessage = 'prefrop';
    for(int i=0; i<players.length; i++){
      if(players[i].stack == 0){
        players[i].actionColor = false;
      }
    }
    int btnPlayerNum = returnBtnNumber();
    players[btnPlayerNum].posision = '';
    int nextBtnNum = nextPlayer(btnPlayerNum);
    actionPlayerNum = nextBtnNum;
    players[nextBtnNum].posision = 'BTN';
    
    //SBのブラインドを計算
    if(players[nextPlayer(actionPlayerNum)].active && players[nextPlayer(actionPlayerNum)].stack == 0){
      //プレイヤーがアクティブかつスタックがない時の処理
      players[nextPlayer(actionPlayerNum)].active = false;
    }else if(players[nextPlayer(actionPlayerNum)].active){
      //プレイヤーがアクティブの時の処理（アクティブじゃないときはデッドボタン）
      nextActionPlayer();
      blindBetAction(smallBlind);
    }

    //BBのブラインドを計算
    nextActionPlayer();
    blindBetAction(bigBlind);

    for(int i=0; i<players.length; i++){
      if(players[nextPlayer(actionPlayerNum)].stack + players[nextPlayer(actionPlayerNum)].betAmount == 0){
        players[nextPlayer(actionPlayerNum)].active = false;
      }
    }


    nextActionPlayer();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poker Chip Count')
      ),
      body: Column(
        children: [
          Container(
            child: Text(
              "SidePot : $displaySidePot",
              style: TextStyle(
                fontSize: 20
              ),
            ),

          ),
          Container(
            height: 80,
            alignment: Alignment.center,
            child: Text(
              "Pot : $displayPot",
              style: TextStyle(
                fontSize: 40
              ),
            ),
          ),
          Expanded(child: 
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0,
                childAspectRatio: 1.5,
                ),
              itemCount: players.length,
              
              itemBuilder: (context, index){
                return InkWell(
                  onTap: !players[index].actionColor ? null : (){
                    bool nextWin = false;
                    if (showdown) {
                      setState(() {
                        if(sidePot.length > 0){
                          //ALL INが入っているときの計算
                          for(int i=0; i<sidePot.length; i++){
                            if(index == allInPlayer[i]){
                              for(int j=i; j>=0; j--){
                                players[index].stack += sidePot[j];
                                players[allInPlayer[j]].actionColor = false;
                                actionPlayerList.remove(allInPlayer[j]);
                                sidePot.removeAt(j);
                                allInPlayer.removeAt(j);
                              }
                              nextWin = true;
                              break;
                            }
                          }
                          //残り一人の場合はpotをそのプレイヤーのstackに足す
                          if(actionPlayerList.length == 1){
                            players[actionPlayerList[0]].stack += pot;
                            pot = 0;
                            showdown = false;
                            nextWin = false;
                          }else if(!nextWin){
                            //ALL IN側じゃないほうが勝利した場合はサイドポットとメインポットをstackに足す
                            for(int i=0; i<sidePot.length; i++){
                              players[index].stack += sidePot[i];
                            }
                            sidePot = [];
                            allInPlayer = [];
                            players[index].stack += pot;
                            pot = 0;
                            showdown = false;
                          }
                          //残りのプレイヤーがいる場合はもう一度winplayerの選択
                          if(nextWin){
                            nextStreet();
                          }else{
                            startNewGame();
                          }
                        }else{
                          //ALL INが入っていない場合の計算
                          players[index].stack += pot;
                          pot = 0;
                          showdown = false;
                          startNewGame();
                        }
                      });
                    }
                  },
                  child: Container(
                    //Playerの枠
                    color: players[index].actionColor ? Colors.greenAccent : Colors.grey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            //プレイヤー名の表示
                            Container(
                              child: Text(
                                players[index].playerName,
                                style: TextStyle(
                                  fontSize: 30
                                ),
                              ),
                            ),
                            Container(
                              //アクションの表示
                              child: Text(
                                players[index].action,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red
                                ),
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            //スタックの表示
                            (players[index].stack - players[index].betAmount).toString(),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            //ボタンの表示
                            players[index].posision,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Center(
                          //ベット金額の表示
                          child: Text(
                            'Bet : ' + players[index].betAmount.toString(),
                            style: TextStyle(
                              fontSize: 20
                            ),
                          ),
                        ),
                
                    ]),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 30,
            child: Text(
              //アクションを促すメッセージの表示
              actionMessage,
              style: TextStyle(
                fontSize: 15,
                color:Colors.redAccent ,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                //back actionボタン
                padding: EdgeInsets.only(right: 50,left: 20),
                child: ElevatedButton(
                  onPressed:(){
                    
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    fixedSize: Size.fromWidth(110),
                    padding:  EdgeInsets.all(10),
                  ),
                  child:Text(
                    'Back action',
                  ),
                ),
              ),
              Container(
                //ベット金額の表示（入力可）
                width: 200,
                height: 50,
                child: TextFormField(
                  onChanged: (text){
                    setState(() {
                      int betCulcuration = 0;
                      betCulcuration = int.tryParse(text) ?? 0;
                      if(betCulcuration > players[actionPlayerNum].stack){
                        betTextController.text = players[actionPlayerNum].stack.toString();
                      }
                    });
                  },
                  controller: betTextController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  hintText: 'input bet amount',
                  
              ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ElevatedButton(
              //フォールドボタン
              onPressed: (playerNum==0) ?null : (){
                players[actionPlayerNum].actionColor = false;
                setState(() {
                  nextActionPlayer();
                  if(actionPlayerList[0] == actionPlayerNum){
                    if(playerNum == 1){
                      players[actionPlayerNum].stack += pot;
                      pot = 0;
                      startNewGame();
                    }else{
                      nextStreet();
                    }
                  }else{
                    actionMessageGenerate();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                fixedSize: Size.fromWidth(110),
              ),
              child:Text(
                'Fold',
                ),
              ),
              ElevatedButton(
              //チェック／コールボタン
              onPressed: !buttonActive ? null : (){
                checkCallAction();
                nextActionPlayer();
                if(actionPlayerList[0] == actionPlayerNum){
                  nextStreet();
                }
                actionMessageGenerate();
                setState(() {
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: Size.fromWidth(110),
              ),
              child:Text(
                'Check/Call',
                ),
              ),
              ElevatedButton(
                //レイズボタン
                onPressed:!buttonActive ? null : (){
                  //レイズ後のアクション
                  setState(() {
                    if(raiseAction()){
                      nextActionPlayer();
                      actionMessageGenerate();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orangeAccent,
                  fixedSize: Size.fromWidth(110),
                ),
                child:Text(
                  'Raise',
                  ),
                ),
          ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ElevatedButton(
              onPressed: (){
                //ベット金額を増やす（100）
                setState(() {
                  int betCulcuration = 0;
                  betCulcuration = int.tryParse(betTextController.text) ?? 0;
                  betCulcuration += 100;
                  if(betCulcuration < players[actionPlayerNum].stack){
                    betTextController.text = betCulcuration.toString();
                  }else{
                    betTextController.text = players[actionPlayerNum].stack.toString();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(110),
              ),
              child:Text(
                "+100",
                ),
              ),
              ElevatedButton(
              onPressed: (){
                setState(() {
                  //ベット金額を増やす（1000）
                  int betCulcuration = 0;
                  betCulcuration = int.tryParse(betTextController.text) ?? 0;
                  betCulcuration += 1000;
                  if(betCulcuration < players[actionPlayerNum].stack){
                    betTextController.text = betCulcuration.toString();
                  }else{
                    betTextController.text = players[actionPlayerNum].stack.toString();
                  }
                                    
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(110),
              ),
              child:Text(
                "+1000",
                ),
              ),
              ElevatedButton(
                //ベット金額を減らす（-1000）
              onPressed: (){
                setState(() {
                  int betCulcuration = 0;
                  betCulcuration = int.tryParse(betTextController.text) ?? 0;
                  betCulcuration -= 1000;
                  if(betCulcuration > 0){
                    betTextController.text = betCulcuration.toString();
                  }else{
                    betTextController.text = '0';
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(110),
              ),
              child:Text(
                "-1000",
                ),
              ),
          ],),
        ],
      ),
    );
  }
}