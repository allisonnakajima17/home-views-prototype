import { useFeed } from './hooks/useFeed'
import { DEFAULT_USER_PROFILES } from './lib/feedApi'

function App() {
  const profile = DEFAULT_USER_PROFILES[3] // "2 Teams (Popular)" — Chiefs + Cowboys
  const { items, loading, error, endOfFeed, loadMore, loadingMore } = useFeed({
    teamIds: profile.team_ids,
  })

  return (
    <div className="min-h-screen bg-black text-white p-6 max-w-md mx-auto">
      <h1 className="text-2xl font-bold mb-1">Feed verification</h1>
      <p className="text-sm text-white/40 mb-6">
        Persona: {profile.label} &middot; {items.length} items loaded
      </p>

      {loading && <p className="text-white/50">Loading feed…</p>}
      {error && <p className="text-red-400">Error: {error}</p>}

      <div className="space-y-4">
        {items.map((item, i) => (
          <div key={item.content_id ?? i} className="bg-white/5 rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-xs font-medium bg-white/10 rounded-full px-2 py-0.5">
                {item.content_type}
              </span>
              {item.primaryTopic?.name && (
                <span className="text-xs text-white/40">{item.primaryTopic.name}</span>
              )}
            </div>
            <p className="font-semibold leading-snug">
              {item.promoHed || item.headline || item.title || item.text?.slice(0, 120) || '(no headline)'}
            </p>
            {item.dek && (
              <p className="text-sm text-white/50 mt-1 line-clamp-2">{item.dek}</p>
            )}
            {item.image?.url && (
              <img
                src={item.image.url}
                alt=""
                className="mt-3 rounded-lg w-full object-cover aspect-video"
              />
            )}
          </div>
        ))}
      </div>

      {!loading && !endOfFeed && items.length > 0 && (
        <button
          onClick={loadMore}
          disabled={loadingMore}
          className="mt-6 w-full py-3 rounded-xl bg-white/10 hover:bg-white/15 transition-colors text-sm font-medium disabled:opacity-50"
        >
          {loadingMore ? 'Loading more…' : 'Load more'}
        </button>
      )}

      {endOfFeed && (
        <p className="mt-6 text-center text-sm text-white/30">End of feed</p>
      )}
    </div>
  )
}

export default App
