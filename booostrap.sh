if [ -n "$HUYDXENV" ]; then
  echo "start....."
  mysql.server start
  redis-server &
  rails s -p 3000
fi
