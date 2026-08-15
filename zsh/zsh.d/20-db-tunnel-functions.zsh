function db-tunnel-start() {
  local name="$1"

  [[ -z "$name" || -z "${DB_TUNNELS[$name]}" ]] && {
    echo "❌ Unknown tunnel: $name"
    echo "Available tunnels:"
    print -rl -- ${(k)DB_TUNNELS}
    return 1
  }

  local parts=(${(s: :)DB_TUNNELS[$name]})
  local local_port="${parts[1]}"
  local remote_host="${parts[2]}"
  local remote_port="${parts[3]}"
  local jump_host="${parts[4]}"
  local client="${parts[5]}"
  local proxy_host="${parts[6]}"

  echo "🔌 Starting tunnel: $name"
  if [[ -n "$proxy_host" ]]; then
    echo "   localhost:${local_port} → ${remote_host}:${remote_port} via ${proxy_host} → ${jump_host}"
    ssh -fN -J ${proxy_host} -L ${local_port}:${remote_host}:${remote_port} ${jump_host}
  else
    echo "   localhost:${local_port} → ${remote_host}:${remote_port} via ${jump_host}"
    ssh -fN -L ${local_port}:${remote_host}:${remote_port} ${jump_host}
  fi

  if [[ $? -eq 0 ]]; then
    echo "✅ Tunnel started"
    case "$client" in
      mysql) echo "   mysql --host=127.0.0.1 --port=${local_port}" ;;
      psql)  echo "   psql  --host=127.0.0.1 --port=${local_port}" ;;
    esac
  else
    echo "❌ Failed to start tunnel"
  fi
}

function db-tunnel-stop() {
  local name="$1"

  [[ -z "$name" || -z "${DB_TUNNELS[$name]}" ]] && {
    echo "❌ Unknown tunnel: $name"
    return 1
  }

  local local_port
  read local_port _ <<< "${DB_TUNNELS[$name]}"

  local pids
  pids="$(lsof -t -iTCP:${local_port} -sTCP:LISTEN 2>/dev/null)"

  if [[ -n "$pids" ]]; then
    kill $pids
    echo "🛑 Tunnel stopped: $name (port ${local_port})"
  else
    echo "ℹ️ No tunnel found on port ${local_port}"
  fi
}
