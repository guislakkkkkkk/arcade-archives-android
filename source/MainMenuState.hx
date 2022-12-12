package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story',
		'freeplay',
		'options',
		'credits'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, false);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('ottomenu/bg'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var storybg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('ottomenu/storybg'));
		storybg.scrollFactor.set(0, yScroll);
		storybg.setGraphicSize(Std.int(storybg.width * 1.175));
		storybg.antialiasing = ClientPrefs.globalAntialiasing;
		add(storybg);

		story = new FlwSprite(0,0);
		story.loadGraphic(Paths.image('ottomenu/story' + optionShit[story]));
		story.scrollFactor.set(0, yScroll);
		story.setGraphicSize(Std.int(story.width * 1.175));
		story.antialiasing = ClientPrefs.globalAntialiasing;
		add(story);

		freeplay = new FlwSprite(0,0);
		freeplay.loadGraphic(Paths.image('ottomenu/freeplay' + optionShit[freeplay]));
		freeplay.scrollFactor.set(0, yScroll);
		freeplay.setGraphicSize(Std.int(freeplay.width * 1.175));
		freeplay.antialiasing = ClientPrefs.globalAntialiasing;
		add(freeplay);

		settings = new FlwSprite(0,0);
		settings.loadGraphic(Paths.image('ottomenu/settings' + optionShit[options]));
		settings.scrollFactor.set(0, yScroll);
		settings.setGraphicSize(Std.int(settings.width * 1.175));
		settings.antialiasing = ClientPrefs.globalAntialiasing;
		add(settings);
		
		support = new FlwSprite(0,0);
		support.loadGraphic(Paths.image('ottomenu/support' + optionShit[credits]));
		support.scrollFactor.set(0, yScroll);
		support.setGraphicSize(Std.int(support.width * 1.175));
		support.antialiasing = ClientPrefs.globalAntialiasing;
		add(support);

		var overlay:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('ottomenu/overlay'));
		overlay.scrollFactor.set(0, yScroll);
		overlay.setGraphicSize(Std.int(overlay.width * 1.175));
		overlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(overlay);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		story = new FlxTypedGroup<FlxSprite>();
		add(story);

		freeplay = new FlxTypedGroup<FlxSprite>();
		add(freeplay);

		freeplay = new FlxTypedGroup<FlxSprite>();
		add(options);

		credits = new FlxTypedGroup<FlxSprite>();
		add(credits);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var story:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			story.scale.x = scale;
			story.scale.y = scale;
			story.frames = Paths.getSparrowAtlas('ottomenu/story' + optionShit[i]);
			story.animation.addByPrefix('storyButton');
			story.animation.addByPrefix('storyHover');
			story.animation.play('storyButton');
			story.ID = i;
			story.add(story);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			story.scrollFactor.set(0, scr);
			story.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			story.updateHitbox();
			
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var freeplay:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			freeplay.scale.x = scale;
			freeplay.scale.y = scale;
			freeplay.frames = Paths.getSparrowAtlas('ottomenu/freeplay' + optionShit[i]);
			freeplay.animation.addByPrefix('freeplayButton');
			freeplay.animation.addByPrefix('freeplayHover');
			freeplay.animation.play('freeplayButton');
			freeplay.ID = i;
			freeplay.add(freeplay);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			freeplay.scrollFactor.set(0, scr);
			freeplay.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			freeplay.updateHitbox();
			
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var options:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			options.scale.x = scale;
			options.scale.y = scale;
			options.frames = Paths.getSparrowAtlas('ottomenu/options' + optionShit[i]);
			options.animation.addByPrefix('optionsButton');
			options.animation.addByPrefix('optionsHover');
			options.animation.play('optionsButton');
			options.ID = i;
			options.add(options);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			options.scrollFactor.set(0, scr);
			options.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			options.updateHitbox();
			
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var credits:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			credits.scale.x = scale;
			credits.scale.y = scale;
			credits.frames = Paths.getSparrowAtlas('ottomenu/credits' + optionShit[i]);
			credits.animation.addByPrefix('creditsButton');
			credits.animation.addByPrefix('creditsHover');
			credits.animation.play('creditsButton');
			credits.ID = i;
			credits.add(credits);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			credits.scrollFactor.set(0, scr);
			credits.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			credits.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

                #if android
                addVirtualPad(UP_DOWN, A_B);
                #end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
