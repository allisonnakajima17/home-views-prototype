interface LeagueTheme {
  color: string;
  abbrev: string;
}

const THEMES: Record<string, LeagueTheme> = {
  nba:            { color: '#1d428a', abbrev: 'NBA' },
  nfl:            { color: '#013369', abbrev: 'NFL' },
  mlb:            { color: '#002d72', abbrev: 'MLB' },
  nhl:            { color: '#000000', abbrev: 'NHL' },
  ncaaf:          { color: '#c8102e', abbrev: 'NCAAF' },
  ncaab:          { color: '#0057b8', abbrev: 'NCAAB' },
  'college football': { color: '#c8102e', abbrev: 'CFB' },
  'college basketball': { color: '#0057b8', abbrev: 'CBB' },
  mls:            { color: '#8b0d2b', abbrev: 'MLS' },
  soccer:         { color: '#326295', abbrev: 'SOC' },
  golf:           { color: '#006747', abbrev: 'GOLF' },
  tennis:         { color: '#4e2a84', abbrev: 'TEN' },
  fantasy:        { color: '#00b4d8', abbrev: 'FAN' },
  wnba:           { color: '#f56600', abbrev: 'WNBA' },
  ufc:            { color: '#d20a0a', abbrev: 'UFC' },
};

const DEFAULT_THEME: LeagueTheme = { color: '#5f5f5f', abbrev: '' };

export function getLeagueTheme(topicName: string | undefined | null): LeagueTheme {
  if (!topicName) return DEFAULT_THEME;

  const key = topicName.toLowerCase().trim();

  if (THEMES[key]) return THEMES[key];

  for (const [k, v] of Object.entries(THEMES)) {
    if (key.includes(k)) return v;
  }

  return { color: '#5f5f5f', abbrev: topicName.slice(0, 4).toUpperCase() };
}
