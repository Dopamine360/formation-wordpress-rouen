import React, { useState, useEffect } from 'react';
import { SafeAreaView, View, Text, TextInput, Button, FlatList, TouchableOpacity } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_URL = 'https://api.example.com';

function useAuth() {
  const [token, setToken] = useState<string | null>(null);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const login = async () => {
    const res = await fetch(`${API_URL}/wp-login-proxy`, { // placeholder route served par WP ou backend
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    const data = await res.json();
    if (data.token) {
      setToken(data.token);
      await AsyncStorage.setItem('jwt', data.token);
    }
  };

  useEffect(() => { AsyncStorage.getItem('jwt').then(setToken); }, []);
  return { token, email, setEmail, password, setPassword, login };
}

const ReferendumList: React.FC<{ token: string; onSelect: (r: any) => void }> = ({ token, onSelect }) => {
  const [items, setItems] = useState<any[]>([]);
  useEffect(() => {
    fetch(`${API_URL}/referendums`, { headers: { Authorization: `Bearer ${token}` }})
      .then((r) => r.json())
      .then(setItems);
  }, [token]);
  return (
    <FlatList
      data={items}
      keyExtractor={(item) => item.id.toString()}
      renderItem={({ item }) => (
        <TouchableOpacity onPress={() => onSelect(item)}>
          <Text style={{ fontSize: 18, fontWeight: 'bold' }}>{item.title}</Text>
          <Text>{item.description}</Text>
        </TouchableOpacity>
      )}
    />
  );
};

const VoteScreen: React.FC<{ referendum: any; token: string; onVoted: () => void }> = ({ referendum, token, onVoted }) => {
  const [choice, setChoice] = useState<number | null>(null);
  const submit = async () => {
    if (!choice) return;
    await fetch(`${API_URL}/votes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify({ referendum_id: referendum.id, choice_id: choice, wp_user_id: 0 })
    });
    onVoted();
  };
  return (
    <View>
      <Text>{referendum.title}</Text>
      {referendum.choices.map((c: any) => (
        <TouchableOpacity key={c.id} onPress={() => setChoice(c.id)}>
          <Text style={{ padding: 8, backgroundColor: choice === c.id ? '#cce' : '#eee' }}>{c.label}</Text>
        </TouchableOpacity>
      ))}
      <Button title="Voter" onPress={submit} />
    </View>
  );
};

const MyVotes: React.FC<{ token: string }> = ({ token }) => {
  const [votes, setVotes] = useState<any[]>([]);
  useEffect(() => {
    fetch(`${API_URL}/me/votes`, { headers: { Authorization: `Bearer ${token}` }})
      .then((r) => r.json())
      .then(setVotes);
  }, [token]);
  return (
    <View>
      <Text style={{ fontWeight: 'bold' }}>Mes votes</Text>
      {votes.map((v) => (
        <Text key={v.referendum_id}>{`Référendum ${v.referendum_id} : ${v.label}`}</Text>
      ))}
    </View>
  );
};

const App = () => {
  const auth = useAuth();
  const [selected, setSelected] = useState<any | null>(null);

  if (!auth.token) {
    return (
      <SafeAreaView style={{ padding: 16 }}>
        <Text>Connexion</Text>
        <TextInput placeholder="Email" value={auth.email} onChangeText={auth.setEmail} />
        <TextInput placeholder="Mot de passe" secureTextEntry value={auth.password} onChangeText={auth.setPassword} />
        <Button title="Se connecter" onPress={auth.login} />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, padding: 16 }}>
      {selected ? (
        <VoteScreen referendum={selected} token={auth.token} onVoted={() => setSelected(null)} />
      ) : (
        <View style={{ flex: 1 }}>
          <ReferendumList token={auth.token} onSelect={setSelected} />
          <MyVotes token={auth.token} />
        </View>
      )}
    </SafeAreaView>
  );
};

export default App;
