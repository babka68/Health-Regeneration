#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Health Regeneration", 
	author = "babka68", 
	description = "Регенерация здоровья игрока при получении повреждения.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};

// Global Timer
Handle g_hTimer[MAXPLAYERS + 1];

// ConVar
int g_iMax_Health, g_iAmount_Health;
float g_fInterval;

public void OnPluginStart()
{
	ConVar cvar;
	cvar = CreateConVar("sm_interval_health_regen", "1.0", "Интервал в секундах между восстановлением здоровья (по умолчанию 1.0)", _, true, 0.0, true, 10.0);
	cvar.AddChangeHook(CVarChanged_Interval);
	g_fInterval = cvar.FloatValue;
	
	cvar = CreateConVar("sm_regen_amount_health", "10", "Сколько будет восстановлено здоровья за интервал (по умолчанию 10)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Amount);
	g_iAmount_Health = cvar.IntValue;
	
	cvar = CreateConVar("sm_regen_max_health", "127", "Максимальное количество здоровья до которых нужно восстанавливать здоровье (по умолчанию 100)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Max_Health);
	g_iMax_Health = cvar.IntValue;
	
	AutoExecConfig(true, "health_regeneration");
	
	HookEvent("player_hurt", HookPlayerHurt);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
}

public void CVarChanged_Interval(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	g_fInterval = CVar.FloatValue;
}

public void CVarChanged_Amount(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	g_iAmount_Health = CVar.IntValue;
}

public void CVarChanged_Max_Health(ConVar CVar, const char[] oldValue, const char[] newValue)
{
	g_iMax_Health = CVar.IntValue;
}

public void HookPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	delete g_hTimer[client];
	g_hTimer[client] = CreateTimer(g_fInterval, Regenerate, GetClientUserId(client), TIMER_REPEAT);
}

public Action Regenerate(Handle timer, any UserId)
{
	int client = GetClientOfUserId(UserId);
	
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		int client_health = GetClientHealth(client);
		if (client_health < g_iMax_Health)
		{
			SetEntityHealth(client, client_health + g_iAmount_Health);
			/*char name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			PrintToChat(client, "У игрока %s здоровье %i + Кол-во из квара %i", name, client_health, g_iAmount_Health);*/
			return Plugin_Continue;
		}
		
		else
		{
			SetEntityHealth(client, g_iMax_Health);
			/*char name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			PrintToChat(client, "У игрока %s максимальное кол-во ХП %i", name, g_iMax_Health);*/
			g_hTimer[client] = null;
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	delete g_hTimer[client];
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	Reset();
}

public void OnMapEnd()
{
	Reset();
}

void Reset()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		delete g_hTimer[i];
	}
} 