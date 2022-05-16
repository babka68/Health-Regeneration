#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Health Regeneration", 
	author = "babka68", 
	description = "Регенерация здоровья игрока при получении повреждения.", 
	version = "1.0.2", 
	url = "https://vk.com/zakazserver68"
};
// Offset
int m_iHealth;

// Global Timer
Handle g_hTimer[MAXPLAYERS + 1];

// ConVar
int g_iMax_Health, g_iAmount_Health;
float g_fInterval;

public void OnPluginStart()
{
	if ((m_iHealth = FindSendPropInfo("CCSPlayer", "m_iHealth")) == -1)
	{
		SetFailState("CCSPlayer::m_iHealth");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_interval_health_regen", "1.0", "Интервал в секундах между восстановлением здоровья (по умолчанию 1.0)", _, true, 0.0, true, 10.0);
	cvar.AddChangeHook(CVarChanged_Interval);
	g_fInterval = cvar.FloatValue;
	
	cvar = CreateConVar("sm_regen_amount_health", "10", "Сколько будет восстановлено здоровья за интервал (по умолчанию 10)", _, true, 0.0, true, 1000.0);
	cvar.AddChangeHook(CVarChanged_Amount);
	g_iAmount_Health = cvar.IntValue;
	
	cvar = CreateConVar("sm_regen_max_health", "127", "Максимальное количество здоровья до которых нужно восстанавливать здоровье (по умолчанию 100)", _, true, 0.0, true, 10000.0);
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

public void HookPlayerHurt(Event event, const char[] name1, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	/* char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name)); */
	
	// PrintToChat(client, "nick = %s int client = %i = nick = %s  GetClientOfUserId(event.GetInt(userid) = %i", name, client, name, GetClientOfUserId(event.GetInt("userid")));
	
	delete g_hTimer[client];
	g_hTimer[client] = CreateTimer(g_fInterval, Regenerate, GetClientUserId(client), TIMER_REPEAT);
	// PrintToChat(client, "nick = %s client = %i CreateTimer(g_fInterval, Regenerate, nick = %s GetClientUserId(client) = %i", name, client, name, GetClientUserId(client));
}

public Action Regenerate(Handle timer, any UserId)
{
	int client = GetClientOfUserId(UserId);
	
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		/* char name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name)); */
		
		// PrintToChat(client, "nick = %s client = %i && nick = %s GetClientOfUserId(UserId) = %i", name, client, name, GetClientOfUserId(UserId));
		
		// PrintToChat(client, "nick = %s client = %i nick = %s IsClientInGame(client) = %i nick = %s IsPlayerAlive(client) = %i", name, client, name, IsClientInGame(client), name, IsPlayerAlive(client));
		// Получить информацию о состоянии здоровья клиента в переменную client_health
		int client_health = GetClientHealth(client);
		// PrintToChat(client, "nick = %s client_health = %i = nick = %s GetClientHealth(client) = %i", name, client_health, name, GetClientHealth(client));
		
		/* if (client_health == 1)
		{
			// PrintToChat(client, "nick = %s if (client_health == 1) = %i вы живы?", name, client_health);
		}
		*/
		
		// Если игрок жив и у игрока не максимальное здоровье, лечим его 
		if (client_health > 0 && client_health < g_iMax_Health)
		{
			// PrintToChat(client, "nick = %s client_health > 0 %i nick = %s client_health = %i < nick = %s g_iMax_Health = %i", name, client_health, name, client_health, name, g_iMax_Health);
			// Лечим игрока согласно значению в g_iAmount_Health
			client_health += g_iAmount_Health;
			// PrintToChat(client, "nick = %s client_health = %i += nick = %s g_iAmount_Health = %i", name, client_health, name, g_iAmount_Health);
			// Если здоровье игрока больше максимально допустимого, то приравнимаем его согласно g_iMax_Health
			if (client_health > g_iMax_Health)
			{
				// PrintToChat(client, "nick = %s client_health = %i > nick = %s g_iMax_Health = %i", name, client_health, name, g_iMax_Health);
				client_health = g_iMax_Health;
				// PrintToChat(client, "nick = %s client_health = %i = nick = %s g_iMax_Health = %i", name, client_health, name, g_iMax_Health);
			}
			
			SetEntData(client, m_iHealth, client_health, _, true);
			// PrintToChat(client, "SetEntData(client = %i m_iHealth = %i, client_health - %i", client, m_iHealth, client_health);
			
			if (client_health < g_iMax_Health)
			{
				// PrintToChat(client, "nick = %s client_health = %i < nick = %s g_iMax_Health = %i", name, client_health, name, g_iMax_Health);
				return Plugin_Continue;
			}
		}
	}
	
	g_hTimer[client] = null;
	return Plugin_Stop;
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
