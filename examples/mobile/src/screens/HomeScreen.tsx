import React from 'react';
import { View, Text, StyleSheet, ScrollView, Platform } from 'react-native';
import Card from '../components/Card';

export default function HomeScreen() {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.hero}>
        <Text style={styles.title}>🎯 GitHub Workflow</Text>
        <Text style={styles.title}>Blueprint</Text>
        <Text style={styles.subtitle}>Mobile Example - Expo App</Text>
      </View>

      <Card title="✅ Setup Complete!">
        <Text style={styles.text}>
          This is a minimal Expo application pre-configured with the GitHub
          Workflow Blueprint for demonstration purposes.
        </Text>
      </Card>

      <Card title="📝 Next Steps">
        <Text style={styles.stepText}>1. Setup the blueprint:</Text>
        <Text style={styles.codeText}>./setup/wizard.sh</Text>

        <Text style={styles.stepText}>2. Convert plan to issues:</Text>
        <Text style={styles.codeText}>
          claude /plan-to-issues examples/mobile/plan.json
        </Text>

        <Text style={styles.stepText}>3. Follow the workflow:</Text>
        <Text style={styles.text}>See README.md for step-by-step guide</Text>

        <Text style={styles.stepText}>4. Test the automation:</Text>
        <Text style={styles.text}>Create PRs and watch the magic happen!</Text>
      </Card>

      <Card title="🧪 Quality Checks">
        <Text style={styles.text}>Run these commands to verify:</Text>
        <Text style={styles.codeText}>pnpm run lint</Text>
        <Text style={styles.codeText}>pnpm run type-check</Text>
        <Text style={styles.codeText}>pnpm start</Text>
      </Card>

      <Card title="📚 Documentation">
        <Text style={styles.linkText}>• Quick Start Guide</Text>
        <Text style={styles.linkText}>• Workflows Reference</Text>
        <Text style={styles.linkText}>• Slash Commands</Text>
        <Text style={styles.linkText}>• Test Scenarios</Text>
      </Card>

      <View style={styles.footer}>
        <Text style={styles.footerText}>
          Generated with Claude Code
        </Text>
        <Text style={styles.footerLink}>
          https://claude.com/claude-code
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  hero: {
    alignItems: 'center',
    padding: 32,
    backgroundColor: '#ffffff',
    borderBottomWidth: 2,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1a1a1a',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginTop: 8,
  },
  stepText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginTop: 12,
    marginBottom: 4,
  },
  text: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginBottom: 8,
  },
  codeText: {
    fontSize: 12,
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
    backgroundColor: '#f4f4f4',
    padding: 8,
    borderRadius: 4,
    color: '#333',
    marginBottom: 8,
  },
  linkText: {
    fontSize: 14,
    color: '#6366f1',
    marginBottom: 8,
  },
  footer: {
    alignItems: 'center',
    padding: 32,
    marginTop: 16,
    borderTopWidth: 2,
    borderTopColor: '#e0e0e0',
  },
  footerText: {
    fontSize: 12,
    color: '#999',
  },
  footerLink: {
    fontSize: 12,
    color: '#6366f1',
    marginTop: 4,
  },
});
