def bfs(start_node, end_node)
  node = start_node
  node.visited = true
  queue = []

  queue << node
  while !queue.empty? do
    node = queue.shift

    break if node == end_node

    node.edges.each do |edge|
      next if edge.visited

      edge.visited = true
      edge.parent = node
      queue << edge
    end
  end
  node
end