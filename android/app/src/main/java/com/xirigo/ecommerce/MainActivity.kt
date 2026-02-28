package com.xirigo.ecommerce

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.getValue
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.navigation.XGAppScaffold
import com.xirigo.ecommerce.feature.onboarding.presentation.screen.OnboardingScreen
import com.xirigo.ecommerce.feature.onboarding.presentation.screen.SplashScreen
import com.xirigo.ecommerce.feature.onboarding.presentation.state.OnboardingUiState
import com.xirigo.ecommerce.feature.onboarding.presentation.viewmodel.OnboardingViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val onboardingViewModel: OnboardingViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        val splash = installSplashScreen()
        splash.setKeepOnScreenCondition {
            onboardingViewModel.uiState.value is OnboardingUiState.Loading
        }
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            XGTheme {
                val uiState by onboardingViewModel.uiState.collectAsStateWithLifecycle()

                when (uiState) {
                    is OnboardingUiState.Loading -> SplashScreen()
                    is OnboardingUiState.ShowOnboarding -> OnboardingScreen(
                        viewModel = onboardingViewModel,
                        onNavigateToMain = { /* handled by state observation below */ },
                    )
                    is OnboardingUiState.OnboardingComplete -> XGAppScaffold()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
