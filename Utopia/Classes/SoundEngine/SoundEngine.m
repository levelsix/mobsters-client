//
//  SoundEngine.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "SoundEngine.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"
#import <MediaPlayer/MediaPlayer.h>
#import <cocos2d.h>

@implementation SoundEngine

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(SoundEngine);

- (void) playBackgroundMusic:(NSString *)music loop:(BOOL)loop {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  BOOL play = ![ud boolForKey:MUSIC_DEFAULTS_KEY];
  if (play && [[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
    [[OALSimpleAudio sharedInstance] playBg:music volume:0.5f pan:0.f loop:loop];
  }
}

- (void) stopBackgroundMusic {
  if (_curMusic != kNoMusic) {
    [[OALSimpleAudio sharedInstance] stopBg];
    [self playAmbientMusic:nil];
  }
  _lastPlayedMusic = _curMusic;
  _curMusic = kNoMusic;
}

- (void) resumeBackgroundMusic {
  switch (_lastPlayedMusic) {
    case kMissionMapMusic:
      [self playMissionMapMusic];
      break;
    case kHomeMapMusic:
      [self playHomeMapMusic];
      break;
    case kBattleMusic:
      [self playBattleMusic];
      break;
      
    default:
      break;
  }
}

- (id<ALSoundSource>) playEffect:(NSString *)effect {
  return [self playEffect:effect volume:1.0f pitch:1.0f pan:0.0f loop:NO];
}

- (id<ALSoundSource>) playEffect:(NSString *)effect volume:(float)volume {
  return [self playEffect:effect volume:volume pitch:1.0f pan:0.0f loop:NO];
}

- (id<ALSoundSource>) playEffect:(NSString *)effect volume:(float)volume pitch:(float)pitch pan:(float)pan loop:(bool)loop {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  BOOL play = ![ud boolForKey:SOUND_EFFECTS_DEFAULTS_KEY];
  if (play) {
    return [[OALSimpleAudio sharedInstance] playEffect:effect volume:volume pitch:pitch pan:pan loop:loop];
  }
  return nil;
}

- (void) playAmbientMusic:(NSString *)ambient {
  [self.ambientNoise stop];
  
  if (ambient) {
    self.ambientNoise = [self playEffect:ambient volume:0.5f pitch:1.f pan:0.f loop:YES];
  } else {
    self.ambientNoise = nil;
  }
}

- (void) playHomeMapMusic {
  if (_curMusic != kHomeMapMusic) {
    _curMusic = kHomeMapMusic;
    if (_curMusic != kMissionMapMusic) {
      [self playBackgroundMusic:@"mus_mobsquad_gameplay.mp3" loop:YES];
    }
    [self playAmbientMusic:@"lp_beach_forest_amb.mp3"];
  }
}

- (void) playMissionMapMusic {
  if (_curMusic != kMissionMapMusic) {
    _curMusic = kMissionMapMusic;
    if (_curMusic != kHomeMapMusic) {
      [self playBackgroundMusic:@"mus_mobsquad_gameplay.mp3" loop:YES];
    }
    [self playAmbientMusic:@"lp_city_amb.mp3"];
  }
}

- (void) playBattleMusic {
  if (_curMusic != kBattleMusic) {
    _curMusic = kBattleMusic;
    [self playBackgroundMusic:@"mus_mobsquad_battle.mp3" loop:YES];
    [self playAmbientMusic:nil];
  }
}

+ (void) dialogueBoxOpen {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_dialogue_box.mp3"];
}

+ (void) spriteJump {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_jump.wav" volume:1.f pitch:1.5f pan:0.f loop:NO];
}

+ (void) tutorialBoatScene {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_full_boat_scene.mp3"];
}

+ (void) closeButtonClick {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_cancel_x_button.mp3"];
}

+ (void) generalButtonClick {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_general_click.mp3"];
}

+ (void) menuPopUp {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_notification_box_pop_up.mp3"];
}

+ (void) chatOpened {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_chat_slide_out.mp3"];
}

+ (void) chatClosed {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_chat_slide_in.mp3"];
}

#pragma mark - Home building sounds

+ (void) structSpeedupConstruction {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_time_bar_rise_completion.mp3"];
}

+ (void) structUpgradeClicked {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_upgrade_button.mp3"];
}

+ (void) structDropped {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_building_drop.mp3"];
}

+ (void) structCantPlace {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_cant_place_building.mp3"];
}

+ (void) structSelected {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_tap_on_building.mp3"];
}

+ (void) structCompleted {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_building_complete.mp3"];
}

+ (void) structCollectOil {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_collect_oil_doober.mp3"];
}

+ (void) structCollectCash {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_collect_money_doober.mp3"];
}


#pragma mark - Puzzle sounds

+ (void) puzzleDamageTickStart {
  SoundEngine *se = [SoundEngine sharedSoundEngine];
  [se.damageTick stop];
  se.damageTick = [se playEffect:@"sfx_damage_click_lp.mp3" volume:0.2f pitch:1.f pan:0.f loop:YES];
}

+ (void) puzzleDamageTickStop {
  SoundEngine *se = [SoundEngine sharedSoundEngine];
  [se.damageTick stop];
  se.damageTick = nil;
}

+ (void) puzzleSwapWindow {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_swap_mobster_window_slide_in.mp3"];
}

+ (void) puzzleSwapCharacterChosen {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_choose_mobster_to_swap.mp3"];
}

+ (void) puzzleMonsterDefeated {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_defeated_character_disappear.mp3"];
}

+ (void) puzzleRocketMatch {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_stripe_bomb_match.mp3"];
}

+ (void) puzzlePlaneDrop {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_arial_bomb_drop.mp3"];
}

+ (void) puzzleDestroyPiece {
  //[[SoundEngine sharedSoundEngine] playEffect:@"sfx_destroy_piece.mp3"];
}

+ (void) puzzleBoardExplosion {
  [[SoundEngine sharedSoundEngine] playEffect:@"boardexplosions.aif"];
}

+ (void) puzzleComboCreated {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_destroy_piece.mp3" volume:1.f pitch:0.7f pan:0.f loop:NO];
}

+ (void) puzzleComboFire {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_combo_catch_fire.mp3"];
}

+ (void) puzzleSwapPiece {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_piece_swap.mp3"];
}

+ (void) puzzleOrbsSlideIn {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_match_3_slide_in.mp3"];
}

+ (void) puzzleFirework {
  NSString *str = [NSString stringWithFormat:@"sfx_firework_0%d.mp3", (arc4random()%3)+1];
  [[SoundEngine sharedSoundEngine] playEffect:str volume:0.5f];
}

+ (void) puzzlePiecesDrop {
  NSString *str = [NSString stringWithFormat:@"sfx_piece_fall_0%d.mp3", (arc4random()%3)+1];
  [[SoundEngine sharedSoundEngine] playEffect:str];
}

+ (void) puzzleMakeItRain {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_make_it_rain.mp3"];
}

+ (void) puzzlePvpQueueUISlideIn {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_attack_ui_slide_in.mp3"];
}

+ (void) puzzlePvpQueueUISlideOut {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_attack_ui_slide_out.mp3"];
}

+ (void) puzzleWinLoseUI {
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_win_lose_ui.mp3"];
}

+ (void) puzzleYouWon {
  [[SoundEngine sharedSoundEngine] playEffect:@"stg_win.mp3"];
}

+ (void) puzzleYouLose {
  [[SoundEngine sharedSoundEngine] playEffect:@"stg_lose.mp3"];
}

@end
