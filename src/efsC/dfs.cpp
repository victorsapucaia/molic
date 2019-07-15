#include <unordered_set>
#include <unordered_map>
#include <vector>
#include <string>
#include <stack>
using set              = std::unordered_set<std::string>;
using adj_list         = std::unordered_map<std::string, set>;
using adj_list_element = std::pair<std::string, set>;

/*****************************************
 * In:
 * - adj: A named adjacency list
 * - root: The rooth node
 * Out: All nodes connected to the root
 ***************************************/
VS dfs(Rcpp::List adj, std::string root) {
  VS nodes = adj.names();
  int n = nodes.size();
  std::unordered_map<std::string, bool> visited;
  std::vector<std::string> connected_to_root;
  for( int i = 0; i < n; i++ ) {
    visited.emplace(nodes[i], false); 
  }
  std::stack<std::string> S;
  S.push(root);
  while( !S.empty() ) {
    std::string u = S.top();
    S.pop();
    if( !visited[u] ) {
      visited[u] = true;
      connected_to_root.push_back(u);
      VS adj_u = adj[u];
      for ( auto & w : adj_u ) {
      	if( !visited[w] ) {
      	  S.push(w);
      	}
      }
    }
  }
  return connected_to_root;
}
